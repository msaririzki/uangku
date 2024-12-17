// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'laporan_bloc.dart';

@immutable
sealed class LaporanEvent {}

/// Event dasar untuk mengambil semua laporan
class GetLaporanEvent extends LaporanEvent {}

/// Event untuk mengambil laporan berdasarkan rentang tanggal
/// Parameter:
/// - startDate: Tanggal awal periode
/// - endDate: Tanggal akhir periode
/// 
/// Contoh penggunaan:
/// ```dart
/// bloc.add(GetWhereDateLaporanEvent(
///   startDate: DateTime(2024, 1, 1),
///   endDate: DateTime(2024, 1, 31)
/// ));
/// ```
class GetWhereDateLaporanEvent extends LaporanEvent {
  final DateTime startDate;
  final DateTime endDate;

  GetWhereDateLaporanEvent({
    required this.startDate,
    required this.endDate,
  });
}

/// Event untuk membuat laporan baru
/// Parameter:
/// - model: Model laporan yang berisi data lengkap laporan
/// 
/// Data yang diperlukan dalam model:
/// - nominal (wajib)
/// - categoryName (wajib)
/// - keterangan (opsional)
/// - tanggal
/// - createdAt
class CreateLaporanEvent extends LaporanEvent {
  final LaporanModel model;

  CreateLaporanEvent({required this.model});
}

/// Event untuk memperbarui laporan yang sudah ada
/// Parameter:
/// - uid: ID laporan yang akan diupdate
/// - nominal: Nominal baru
/// - keterangan: Keterangan baru (opsional)
/// - date: Tanggal laporan (untuk reload data)
class UpdateDateLaporanEvent extends LaporanEvent {
  final String uid;
  final int nominal;
  final String? keterangan;
  final DateTime date;

  UpdateDateLaporanEvent({
    required this.uid,
    required this.nominal,
    this.keterangan,
    required this.date,
  });
}

/// Event untuk menghapus laporan
/// Parameter:
/// - uid: ID laporan yang akan dihapus
/// - date: Tanggal laporan (untuk reload data)
class DestroyDateLaporanEvent extends LaporanEvent {
  final String uid;
  final DateTime date;

  DestroyDateLaporanEvent({
    required this.uid,
    required this.date,
  });
}

/// Event untuk menghitung total pemasukan dan pengeluaran
/// Parameter (pilih salah satu):
/// - date: Untuk menghitung dalam satu bulan
/// - startDate & endDate: Untuk menghitung dalam rentang tanggal tertentu
/// 
/// Contoh penggunaan bulanan:
/// ```dart
/// bloc.add(SumMonthNominalEvent(date: DateTime.now()));
/// ```
/// 
/// Contoh penggunaan rentang tanggal:
/// ```dart
/// bloc.add(SumMonthNominalEvent(
///   startDate: DateTime(2024, 1, 1),
///   endDate: DateTime(2024, 12, 31)
/// ));
/// ```
class SumMonthNominalEvent extends LaporanEvent {
  final DateTime? date;
  final DateTime? startDate;
  final DateTime? endDate;

  SumMonthNominalEvent({
    this.date,
    this.startDate,
    this.endDate,
  });
}

/// Event untuk menghasilkan data pie chart
/// Parameter:
/// - startDate: Tanggal awal periode (opsional, default: awal bulan ini)
/// - endDate: Tanggal akhir periode
/// 
/// Data yang dihasilkan:
/// - title: Nama kategori
/// - value: Persentase dari total
/// - color: Warna random untuk chart
class PieChartEvent extends LaporanEvent {
  final DateTime? startDate;
  final DateTime endDate;

  PieChartEvent({
    this.startDate,
    required this.endDate,
  });
}
