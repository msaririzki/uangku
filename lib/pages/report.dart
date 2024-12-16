// / Import library dan modul yang dibutuhkan
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:mob3_uas_klp_02/bloc/laporan/laporan_bloc.dart'; // Bloc untuk state management
import 'package:mob3_uas_klp_02/global_variable.dart'; // Variabel global untuk fungsi konversi
import 'package:mob3_uas_klp_02/listData/list_data.dart'; // Komponen tampilan data list
import 'package:mob3_uas_klp_02/widget/button_select.dart'; // Widget untuk tombol pilihan
import 'package:mob3_uas_klp_02/widget/pie_chart.dart'; // Widget pie chart
import 'package:mob3_uas_klp_02/widget/templete.dart'; // Template layout umum
import 'package:skeletonizer/skeletonizer.dart'; // Skeleton loader untuk efek loading

// Widget utama untuk menampilkan laporan
class Report extends StatelessWidget {
  Report({super.key});

  // Mendapatkan tanggal saat ini
  final DateTime now = DateTime.now();

  // Inisialisasi tiga instance LaporanBloc
  final LaporanBloc bloc1 = LaporanBloc();
  final LaporanBloc bloc2 = LaporanBloc();
  final LaporanBloc bloc3 = LaporanBloc();

  @override
  Widget build(BuildContext context) {
    // Menjalankan event ketika widget selesai di-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bloc1.add(PieChartEvent(endDate: now)); // Event untuk PieChart
      bloc2.add(GetWhereDateLaporanEvent( // Event untuk laporan per bulan
          startDate: DateTime(now.year, now.month, 1),
          endDate: DateTime(now.year, now.month + 1, 0)));
      bloc3.add(SumMonthNominalEvent( // Event untuk menghitung total nominal
          startDate: DateTime(now.year, now.month, 1),
          endDate: DateTime(now.year, now.month + 1, 0)));
    });

    // List skeleton loader untuk animasi loading
    final List<Widget> skeletonLoaders = List.generate(
      6,
      (index) => const Skeletonizer(
        enabled: true,
        child: ListData(
          kategori: 'hallo word', // Placeholder kategori
          keterangan: 'asdsdgjsadkgjsdlkgjaskejf', // Placeholder keterangan
          nominal: 0, // Placeholder nominal
          tipe: '', // Placeholder tipe
        ),
      ),
    );

    return Templete(
      // Layout menggunakan templete
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menampilkan PieChart
          MyPieChart(bloc: bloc1),
          const SizedBox(height: 20), // Spasi antar komponen

          // Builder untuk menampilkan total nominal
          BlocBuilder<LaporanBloc, LaporanState>(
            bloc: bloc3,
            builder: (context, state) {
              if (state is LaporanError) {
                // Menampilkan pesan error jika ada
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is LaporanSumCalculationState) {
                // Menampilkan total nominal dalam widget Container
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 14.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: state.selisih < 0
                            ? Colors.red
                            : Colors.green, // Warna bayangan tergantung nilai
                        offset: const Offset(0, 4),
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            children: [
                              Text('Total', // Teks "Total"
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .displaySmall!),
                              const SizedBox(height: 5),
                              // Menampilkan nominal dalam format Rupiah
                              Text(GlobalVariable.convertToRupiah(state.selisih),
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .displayLarge!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: state.selisih < 0
                                              ? Colors.red
                                              : Colors.green))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
              return const Center(); // Jika state tidak sesuai
            },
          ),
          const SizedBox(height: 20), // Spasi antar komponen

          // Tombol pilihan untuk filter laporan
          ButtonSelect(
            options: const ['Bulan ini', 'Bulan lalu', '3 Bulan'], // Opsi filter
            bloc1: bloc1,
            bloc2: bloc2,
            bloc3: bloc3,
          ),
          const SizedBox(height: 20),

          // Judul "History Laporan"
          Text(
            'History Laporan',
            style: Theme.of(context)
                .primaryTextTheme
                .displayLarge!
                .copyWith(fontWeight: FontWeight.w500),
          ),

          // Consumer untuk menampilkan daftar laporan
          BlocConsumer<LaporanBloc, LaporanState>(
            bloc: bloc2,
            listener: (context, state) {
              if (state is LaporanError) {
                // Pesan error jika ada masalah
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is LaporanSuccess) {
                // Pesan sukses jika ada
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              if (state is LaporanLoading) {
                // Menampilkan skeleton loader saat loading
                return Column(children: skeletonLoaders);
              } else if (state is LaporanLoaded) {
                if (state.dataLaporan.isEmpty) {
                  // Menampilkan teks jika tidak ada laporan
                  return const Center(
                    child: SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          'Laporan belum tersedia',
                          style:
                              TextStyle(color: Colors.black45, fontSize: 20.0),
                        ),
                      ),
                    ),
                  );
                }
                // Menampilkan list laporan
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  itemCount: state.dataLaporan.length,
                  itemBuilder: (context, index) {
                    final data = state.dataLaporan[index];
                    return ListData(
                      uid: data.uid, // ID laporan
                      date: data.tanggal, // Tanggal laporan
                      kategori: data.categoryName, // Kategori laporan
                      tanggal: DateFormat('d MMMM') // Format tanggal
                          .format(data.tanggal)
                          .toString(),
                      keterangan: data.keterangan!, // Keterangan laporan
                      nominal: data.nominal, // Nominal laporan
                      tipe: data.categoryTipe!, // Tipe laporan
                      bloc1: bloc1,
                      bloc2: bloc2,
                      pageLaporan: true, // Penanda halaman laporan
                    );
                  },
                );
              }
              return Column(children: skeletonLoaders); // Jika tidak ada state
            },
          ),
        ],
      ),
    );
  }
}