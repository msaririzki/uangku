part of 'laporan_bloc.dart';

@immutable
sealed class LaporanState {}

/// State awal ketika LaporanBloc diinisialisasi
final class LaporanInitial extends LaporanState {}

/// State yang menunjukkan proses sedang berlangsung
/// Digunakan untuk menampilkan loading indicator
class LaporanLoading extends LaporanState {}

/// State yang menunjukkan data laporan berhasil dimuat
/// Properties:
/// - dataLaporan: List dari LaporanModel yang berisi data laporan
/// 
/// Contoh penggunaan:
/// ```dart
/// if (state is LaporanLoaded) {
///   final laporan = state.dataLaporan;
///   return ListView.builder(
///     itemCount: laporan.length,
///     itemBuilder: (context, index) => LaporanItem(laporan[index])
///   );
/// }
/// ```
class LaporanLoaded extends LaporanState {
  final List<LaporanModel> dataLaporan;

  LaporanLoaded({required this.dataLaporan});
}

/// State yang menunjukkan operasi berhasil dilakukan
/// Properties:
/// - message: Pesan sukses yang akan ditampilkan ke user
class LaporanSuccess extends LaporanState {
  final String message;

  LaporanSuccess({required this.message});
}

/// State yang menunjukkan terjadi error
/// Properties:
/// - message: Pesan error yang akan ditampilkan ke user
class LaporanError extends LaporanState {
  final String message;

  LaporanError({required this.message});
}

/// State yang berisi hasil perhitungan total pemasukan dan pengeluaran
/// Properties:
/// - pemasukan: Total pemasukan dalam periode
/// - pengeluaran: Total pengeluaran dalam periode
/// - selisih: Selisih antara pemasukan dan pengeluaran
/// - data: List laporan dalam periode tersebut
/// 
/// Contoh penggunaan:
/// ```dart
/// if (state is LaporanSumCalculationState) {
///   return Column(
///     children: [
///       Text('Total Pemasukan: ${state.pemasukan}'),
///       Text('Total Pengeluaran: ${state.pengeluaran}'),
///       Text('Selisih: ${state.selisih}')
///     ]
///   );
/// }
/// ```
class LaporanSumCalculationState extends LaporanState {
  final int pemasukan;
  final int pengeluaran;
  final int selisih;
  final List<LaporanModel> data;

  LaporanSumCalculationState({
    required this.pemasukan, 
    required this.pengeluaran, 
    required this.selisih, 
    required this.data
  });
}

/// State yang berisi data untuk pie chart
/// Properties:
/// - dataChart: List map yang berisi data untuk chart
///   Format data: {'title': String, 'value': int, 'color': Color}
/// 
/// Contoh penggunaan:
/// ```dart
/// if (state is LaporanPieChartState) {
///   return PieChart(
///     data: state.dataChart,
///     // konfigurasi chart lainnya
///   );
/// }
/// ```
class LaporanPieChartState extends LaporanState {
  final List dataChart;

  LaporanPieChartState({required this.dataChart});
}
