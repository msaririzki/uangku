/// Screen untuk halaman utama/home aplikasi
/// Menampilkan kalender dan riwayat transaksi harian
/// 
/// Fitur:
/// - Kalender interaktif
/// - Tampilan transaksi per hari
/// - Highlight tanggal yang memiliki transaksi
/// - Loading state dengan skeleton
/// - Error handling

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mob3_uas_klp_02/bloc/laporan/laporan_bloc.dart';
import 'package:mob3_uas_klp_02/listData/list_data.dart';
import 'package:mob3_uas_klp_02/models/laporan_model.dart';
import 'package:mob3_uas_klp_02/widget/card_info.dart';
import 'package:mob3_uas_klp_02/widget/templete.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // State untuk tanggal
  DateTime _today = DateTime.now();
  DateTime? _selectedDay;
  
  // Instance BLoC untuk manajemen state
  final LaporanBloc bloc1 = LaporanBloc(); // Untuk data harian
  final LaporanBloc bloc2 = LaporanBloc(); // Untuk data bulanan

  @override
  void initState() {
    // Load data awal saat widget dibuat
    bloc1.add(GetWhereDateLaporanEvent(startDate: _today, endDate: _today));
    bloc2.add(SumMonthNominalEvent(date: _today));
    super.initState();
  }

  /// Fungsi untuk mendapatkan list transaksi pada tanggal tertentu
  List<LaporanModel> listOfDayEvents(DateTime day, LaporanState state) {
    if (state is LaporanSumCalculationState) {
      return state.data.where((event) {
        return event.tanggal.year == day.year &&
            event.tanggal.month == day.month &&
            event.tanggal.day == day.day;
      }).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    // Range tahun untuk kalender
    final DateTime firstYear = DateTime(_today.year - 1, 1, 1);
    final DateTime lastYear = DateTime(_today.year + 1, 12, 31);

    // List skeleton loader untuk animasi loading
    final List<Widget> skeletonLoaders = List.generate(
      6,
      (index) => const Skeletonizer(
        enabled: true,
        child: ListData(
          kategori: 'hallo word',
          keterangan: 'asdsdgjsadkgjsdlkgjaskejf',
          nominal: 0,
          tipe: '',
        ),
      ),
    );

    return Scaffold(
      body: Templete(
        withScrollView: false,
        content: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Konten utama dengan scroll
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Widget kalender
                    BlocBuilder<LaporanBloc, LaporanState>(
                      bloc: bloc2,
                      builder: (context, state) {
                        return TableCalendar(
                          firstDay: firstYear,
                          lastDay: lastYear,
                          focusedDay: _today,
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          eventLoader: (day) => listOfDayEvents(day, state),
                          // Handler perubahan bulan
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _today = focusedDay;
                            });
                            bloc2.add(SumMonthNominalEvent(date: focusedDay));
                          },
                          // Handler pemilihan tanggal
                          onDaySelected: (selectedDay, focusedDay) {
                            if (!isSameDay(_selectedDay, selectedDay)) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _today = focusedDay;
                              });
                              bloc1.add(GetWhereDateLaporanEvent(
                                  startDate: selectedDay,
                                  endDate: selectedDay));
                            }
                          },
                          // Kustomisasi tampilan kalender
                          calendarBuilders: CalendarBuilders(
                            // Kustomisasi header hari
                            dowBuilder: (context, day) {
                              if (day.weekday == DateTime.sunday) {
                                final text = DateFormat.E().format(day);
                                return Center(
                                  child: Text(
                                    text,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }
                              return null;
                            },
                            // Kustomisasi tanggal
                            defaultBuilder: (context, day, focusedDay) {
                              if (day.weekday == DateTime.sunday) {
                                return Center(
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Judul riwayat
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'Riwayat',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .displayLarge!
                            .copyWith(
                                fontWeight: FontWeight.w500, fontSize: 20.0),
                      ),
                    ),
                    // Daftar transaksi
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: [
                          BlocConsumer<LaporanBloc, LaporanState>(
                            bloc: bloc1,
                            // Handler untuk state changes
                            listener: (context, state) {
                              if (state is LaporanError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.message)),
                                );
                              } else if (state is LaporanSuccess) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.message)),
                                );
                              }
                            },
                            // Builder untuk UI
                            builder: (context, state) {
                              if (state is LaporanLoading) {
                                return Column(children: skeletonLoaders);
                              } else if (state is LaporanLoaded) {
                                if (state.dataLaporan.isEmpty) {
                                  return const Center(
                                    child: SizedBox(
                                      height: 100,
                                      child: Center(
                                        child: Text(
                                          'Laporan belum tersedia',
                                          style: TextStyle(
                                              color: Colors.black45,
                                              fontSize: 20.0),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                                  itemCount: state.dataLaporan.length,
                                  itemBuilder: (context, index) {
                                    final data = state.dataLaporan[index];
                                    return ListData(
                                      uid: data.uid,
                                      date: data.tanggal,
                                      kategori: data.categoryName,
                                      keterangan: data.keterangan!,
                                      nominal: data.nominal,
                                      tipe: data.categoryTipe!,
                                      bloc1: bloc1,
                                      bloc2: bloc2,
                                    );
                                  },
                                );
                              }
                              return Column(children: skeletonLoaders);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Card info di bagian atas
            Positioned(
              top: -20,
              child: CardInfo(bloc: bloc2),
            ),
          ],
        ),
      ),
    );
  }
}
