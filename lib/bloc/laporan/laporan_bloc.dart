/// File ini berisi implementasi LaporanBloc yang menangani logika manajemen laporan keuangan
/// menggunakan BLoC (Business Logic Component) pattern.
/// 
/// LaporanBloc mengelola:
/// - Pembuatan laporan keuangan
/// - Pengambilan data laporan berdasarkan tanggal
/// - Perhitungan total pemasukan/pengeluaran
/// - Pembuatan data untuk pie chart
/// - Pembaruan dan penghapusan laporan

import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_02/models/laporan_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'laporan_event.dart';
part 'laporan_state.dart';

/// LaporanBloc adalah kelas utama yang mengimplementasikan BLoC pattern untuk manajemen laporan.
/// Kelas ini menangani semua event terkait laporan dan mengubah state sesuai hasil prosesnya.
class LaporanBloc extends Bloc<LaporanEvent, LaporanState> {
  // Instance Firestore untuk akses database
  final db = FirebaseFirestore.instance;
  // Instance UUID untuk generate ID unik
  final Uuid uuid = const Uuid();

  LaporanBloc() : super(LaporanInitial()) {
    /// Handler untuk CreateLaporanEvent
    /// Menangani pembuatan laporan baru dengan validasi:
    /// - Nominal harus lebih dari 0
    /// - Kategori harus dipilih
    on<CreateLaporanEvent>((event, emit) async {
      emit(LaporanLoading());

      try {
        final String userId = await getIdUser();
        final String generateUid = uuid.v4();
        late String categoryTipe;
        late String categoryName;

        // Validasi input
        if (event.model.nominal <= 0 ||
            event.model.categoryName.isEmpty ||
            event.model.categoryName == '') {
          return emit(LaporanError(message: 'Harap mengisi form yang wajib'));
        }

        // Cek keberadaan kategori
        QuerySnapshot snapshot = await db
            .collection("category")
            .where('name', isEqualTo: event.model.categoryName)
            .where('userId', isEqualTo: userId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          categoryTipe = snapshot.docs.first['category'];
          categoryName = snapshot.docs.first['name'];
        } else {
          return emit(LaporanError(message: 'Category tidak ditemukan'));
        }

        // Simpan laporan ke Firestore
        await db.collection("laporan").doc(generateUid).set({
          "uid": generateUid,
          "userId": userId,
          "keterangan": event.model.keterangan,
          "nominal": event.model.nominal,
          "categoryTipe": categoryTipe,
          "categoryName": categoryName,
          "tanggal": event.model.tanggal,
          "createdAt": event.model.createdAt,
        });

        emit(LaporanSuccess(message: 'Berhasil input laporan'));
      } catch (e) {
        emit(LaporanError(message: e.toString()));
      }
    });

    /// Handler untuk GetWhereDateLaporanEvent
    /// Mengambil laporan berdasarkan rentang tanggal
    on<GetWhereDateLaporanEvent>(
      (event, emit) async {
        emit(LaporanLoading());

        // Set waktu awal dan akhir untuk query
        final DateTime startDay = DateTime(event.startDate.year,
            event.startDate.month, event.startDate.day, 0, 0, 0, 0);
        final DateTime endDay = DateTime(event.endDate.year,
            event.endDate.month, event.endDate.day, 23, 59, 59, 999);

        try {
          await _getWhereDateLaporan(startDay, endDay, emit);
        } catch (e) {
          emit(LaporanError(message: e.toString()));
        }
      },
    );

    /// Handler untuk UpdateDateLaporanEvent
    /// Memperbarui data laporan yang sudah ada
    on<UpdateDateLaporanEvent>(
      (event, emit) async {
        emit(LaporanLoading());

        // Set rentang waktu untuk reload data
        final DateTime startDay = DateTime(
            event.date.year, event.date.month, event.date.day, 0, 0, 0, 0);
        final DateTime endDay = DateTime(
            event.date.year, event.date.month, event.date.day, 23, 59, 59, 999);

        // Ambil data laporan yang akan diupdate
        final getData = db.collection("laporan").doc(event.uid);
        final docSnapshot = await getData.get();

        if (!docSnapshot.exists) {
          emit(LaporanError(message: 'Laporan not found.'));
          return;
        }

        try {
          // Update data laporan
          await getData.update(
              {"keterangan": event.keterangan, "nominal": event.nominal});
          emit(LaporanSuccess(message: 'Berhasil update laporan'));
          await _getWhereDateLaporan(startDay, endDay, emit);
        } catch (e) {
          emit(LaporanError(message: e.toString()));
        }
      },
    );

    /// Handler untuk DestroyDateLaporanEvent
    /// Menghapus laporan yang dipilih
    on<DestroyDateLaporanEvent>(
      (event, emit) async {
        emit(LaporanLoading());

        // Set rentang waktu untuk reload data
        final DateTime startDay = DateTime(
            event.date.year, event.date.month, event.date.day, 0, 0, 0, 0);
        final DateTime endDay = DateTime(
            event.date.year, event.date.month, event.date.day, 23, 59, 59, 999);

        try {
          // Hapus laporan
          db.collection("laporan").doc(event.uid).delete();

          emit(LaporanSuccess(message: 'Berhasil hapus data'));
          await _getWhereDateLaporan(startDay, endDay, emit);
        } catch (e) {
          emit(LaporanError(message: e.toString()));
        }
      },
    );

    /// Handler untuk SumMonthNominalEvent
    /// Menghitung total pemasukan, pengeluaran, dan selisih dalam periode tertentu
    on<SumMonthNominalEvent>(
      (event, emit) async {
        emit(LaporanLoading());

        DateTime startDate = DateTime.now();
        DateTime endDate = DateTime.now();

        final String userId = await getIdUser();
        
        // Set rentang waktu berdasarkan parameter yang diterima
        if (event.startDate != null && event.endDate != null) {
          startDate = DateTime(event.startDate!.year, event.startDate!.month,
              event.startDate!.day, 0, 0, 0, 0);
          endDate = DateTime(event.endDate!.year, event.endDate!.month,
              event.endDate!.day, 23, 59, 59, 999);
        } else {
          // Jika tidak ada parameter, ambil data satu bulan
          startDate = DateTime(event.date!.year, event.date!.month, 1);
          endDate = DateTime(
            startDate.year,
            startDate.month + 1,
            0, // Hari terakhir bulan
            23, // Jam
            59, // Menit
            59, // Detik
            999, // Milidetik
          );
        }

        final Timestamp startTimestamp = Timestamp.fromDate(startDate);
        final Timestamp endTimestamp = Timestamp.fromDate(endDate);

        try {
          // Ambil data pemasukan
          QuerySnapshot queryPemasukan = await db
              .collection('laporan')
              .where('userId', isEqualTo: userId)
              .where('categoryTipe', isEqualTo: 'Pemasukan')
              .where('tanggal', isGreaterThanOrEqualTo: startTimestamp)
              .where('tanggal', isLessThan: endTimestamp)
              .get();

          // Ambil data pengeluaran
          QuerySnapshot queryPengeluaran = await db
              .collection('laporan')
              .where('userId', isEqualTo: userId)
              .where('categoryTipe', isEqualTo: 'Pengeluaran')
              .where('tanggal', isGreaterThanOrEqualTo: startTimestamp)
              .where('tanggal', isLessThan: endTimestamp)
              .get();

          // Hitung total pemasukan
          int totalPemasukan = queryPemasukan.docs.fold(0, (data, doc) {
            final value = (doc.data() as Map<String, dynamic>)['nominal'] ?? 0;
            return data + (value is num ? value.toInt() : 0);
          });

          // Hitung total pengeluaran
          int totalPengeluaran = queryPengeluaran.docs.fold(0, (data, doc) {
            final value = (doc.data() as Map<String, dynamic>)['nominal'] ?? 0;
            return data + (value is num ? value.toInt() : 0);
          });

          // Hitung selisih
          int selisih = totalPemasukan - totalPengeluaran;

          // Konversi data ke model
          final List<LaporanModel> pemasukanList = queryPemasukan.docs
              .map((item) => LaporanModel(
                  nominal: item['nominal'],
                  categoryName: item['categoryName'],
                  tanggal: (item['tanggal'] as Timestamp).toDate(),
                  createdAt: (item['createdAt'] as Timestamp).toDate()))
              .toList();

          final List<LaporanModel> pengeluaranList = queryPengeluaran.docs
              .map((item) => LaporanModel(
                  nominal: item['nominal'],
                  categoryName: item['categoryName'],
                  tanggal: (item['tanggal'] as Timestamp).toDate(),
                  createdAt: (item['createdAt'] as Timestamp).toDate()))
              .toList();

          // Gabungkan data pemasukan dan pengeluaran
          List<LaporanModel> laporanData = [
            ...pemasukanList,
            ...pengeluaranList
          ];

          emit(LaporanSumCalculationState(
              pemasukan: totalPemasukan,
              pengeluaran: totalPengeluaran,
              selisih: selisih,
              data: laporanData));
        } catch (e) {
          emit(LaporanError(message: e.toString()));
        }
      },
    );

    /// Handler untuk PieChartEvent
    /// Menyiapkan data untuk ditampilkan dalam bentuk pie chart
    on<PieChartEvent>(
      (event, emit) async {
        emit(LaporanLoading());

        final String userId = await getIdUser();
        final Random random = Random();

        // Set rentang waktu untuk data chart
        final DateTime now = DateTime.now();
        final DateTime startDate = event.startDate != null
            ? DateTime(event.startDate!.year, event.startDate!.month, 1)
            : DateTime(now.year, now.month, 1);
        final DateTime endDate = DateTime(
            event.endDate.year, event.endDate.month + 1, 0, 23, 59, 59, 999);
        final Timestamp startTimestamp = Timestamp.fromDate(startDate);
        final Timestamp endTimestamp = Timestamp.fromDate(endDate);

        try {
          // Ambil semua kategori
          final QuerySnapshot getCategories = await db
              .collection('category')
              .where('userId', isEqualTo: userId)
              .get();

          // Siapkan data untuk chart
          final dataChart =
              await Future.wait(getCategories.docs.map((item) async {
            // Hitung total nominal per kategori
            final QuerySnapshot laporan = await db
                .collection('laporan')
                .where('userId', isEqualTo: userId)
                .where('categoryName', isEqualTo: item['name'])
                .where('tanggal', isGreaterThanOrEqualTo: startTimestamp)
                .where('tanggal', isLessThanOrEqualTo: endTimestamp)
                .get();

            int sumNominal = laporan.docs.fold(0, (data, doc) {
              final value =
                  (doc.data() as Map<String, dynamic>)['nominal'] ?? 0;
              return data + (value is num ? value.toInt() : 0);
            });

            // Format data untuk chart dengan warna random
            return {
              'title': item['name'],
              'value': sumNominal,
              'color': Color.fromRGBO(
                random.nextInt(256),
                random.nextInt(256),
                random.nextInt(256),
                1,
              )
            };
          }).toList());

          // Hitung total keseluruhan untuk persentase
          int totalNominal = dataChart.fold(0, (data, doc) {
            final value = (doc)['value'] ?? 0;
            return data + (value is num ? value.toInt() : 0);
          });

          // Konversi nominal ke persentase
          for (var item in dataChart) {
            item['value'] =
                (((item['value'] as int) / totalNominal) * 100).round();
          }

          emit(LaporanPieChartState(dataChart: dataChart));
        } catch (e) {
          emit(LaporanError(message: e.toString()));
        }
      },
    );
  }

  /// Fungsi helper untuk mendapatkan ID user dari SharedPreferences
  Future<String> getIdUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid') ?? '';
  }

  /// Fungsi helper untuk mengambil data laporan berdasarkan rentang tanggal
  Future<void> _getWhereDateLaporan(
      DateTime startDay, DateTime endDay, Emitter<LaporanState> emit) async {
    final String userId = await getIdUser();
    final Timestamp startTimestamp = Timestamp.fromDate(startDay);
    final Timestamp endTimestamp = Timestamp.fromDate(endDay);

    try {
      // Ambil data laporan dari Firestore
      final QuerySnapshot getLaporan = await db
          .collection('laporan')
          .where('tanggal', isGreaterThanOrEqualTo: startTimestamp)
          .where('tanggal', isLessThanOrEqualTo: endTimestamp)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      // Konversi data ke model LaporanModel
      final result = getLaporan.docs
          .map((data) => LaporanModel(
                uid: data['uid'],
                keterangan: data['keterangan'],
                nominal: data['nominal'],
                categoryTipe: data['categoryTipe'],
                categoryName: data['categoryName'],
                tanggal: (data['tanggal'] as Timestamp).toDate(),
                createdAt: (data['createdAt'] as Timestamp).toDate(),
              ))
          .toList();

      emit(LaporanLoaded(dataLaporan: result));
    } catch (e) {
      emit(LaporanError(message: e.toString()));
    }
  }
}
