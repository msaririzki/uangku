/// Widget untuk menampilkan item laporan keuangan dalam bentuk list
/// dengan fitur slidable untuk edit dan hapus
/// 
/// Fitur:
/// - Menampilkan detail laporan (kategori, tanggal, nominal, keterangan)
/// - Swipe kiri untuk akses menu edit dan hapus
/// - Warna nominal sesuai tipe (hijau untuk pemasukan, merah untuk pengeluaran)
/// - Format nominal dalam Rupiah

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mob3_uas_klp_02/bloc/laporan/laporan_bloc.dart';
import 'package:mob3_uas_klp_02/global_variable.dart';
import 'package:mob3_uas_klp_02/widget/dialog.dart';

class ListData extends StatelessWidget {
  // Properties untuk data laporan
  final String? uid;              // ID unik laporan
  final String kategori;          // Nama kategori
  final String? tanggal;          // Tanggal laporan (format string)
  final int nominal;              // Jumlah uang
  final String keterangan;        // Catatan tambahan
  final String tipe;              // Tipe laporan (Pemasukan/Pengeluaran)
  final DateTime? date;           // Tanggal untuk reload data
  
  // BLoC untuk update state
  final LaporanBloc? bloc1;       // BLoC utama
  final LaporanBloc? bloc2;       // BLoC kedua (jika ada)
  
  // Flag untuk kontrol tampilan
  final bool? pageLaporan;        // True jika di halaman laporan

  const ListData({
    super.key,
    this.uid,
    required this.kategori,
    this.tanggal,
    required this.nominal,
    required this.keterangan,
    required this.tipe,
    this.date,
    this.bloc1,
    this.bloc2,
    this.pageLaporan = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Slidable(
        key: const ValueKey(0),
        // Konfigurasi aksi slide dari kiri
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            // Tombol hapus (merah)
            SlidableAction(
              onPressed: (context) {
                DialogWidget.deleteLaporan(
                    context, bloc1!, bloc2!, uid!, date!);
              },
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
            ),
            // Tombol edit (biru)
            SlidableAction(
              onPressed: (context) {
                DialogWidget.editLaporan(
                  context,
                  bloc1!,
                  bloc2!,
                  uid!,
                  date!,
                  keterangan,
                  nominal.toString(),
                );
              },
              backgroundColor: const Color(0xFF21B7CA),
              foregroundColor: Colors.white,
              icon: Icons.edit,
            ),
          ],
        ),
        // Nonaktifkan slidable jika di halaman laporan
        enabled: pageLaporan! ? false : true,
        // Konten utama item
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kolom kiri: kategori dan tanggal
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  kategori,
                  style: Theme.of(context).primaryTextTheme.displayMedium,
                ),
                if (tanggal != null)
                  Text(
                    tanggal!,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .displaySmall!
                        .copyWith(color: Colors.black26),
                  ),
              ]),
              // Nominal di kanan dengan warna sesuai tipe
              Text(
                GlobalVariable.convertToRupiah(nominal),
                style: Theme.of(context)
                    .primaryTextTheme
                    .displayMedium
                    ?.copyWith(
                        color: tipe == 'Pemasukan' ? Colors.green : Colors.red),
              )
            ],
          ),
          const SizedBox(height: 10),
          // Keterangan (jika ada)
          if (keterangan.isNotEmpty)
            Text(
              keterangan,
              textAlign: TextAlign.left,
              style: Theme.of(context)
                  .primaryTextTheme
                  .displaySmall!
                  .copyWith(fontWeight: FontWeight.w300, letterSpacing: 0.4),
            ),
          // Garis pembatas antar item
          const Divider(
            color: Colors.black54,
            thickness: 1,
            height: 20,
          ),
        ]),
      ),
    ]);
  }
}
