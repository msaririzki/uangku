part of 'category_bloc.dart';

@immutable
sealed class CategoryState {}

/// State awal ketika CategoryBloc diinisialisasi
final class CategoryInitial extends CategoryState {}

/// State yang menunjukkan proses sedang berlangsung
/// Digunakan untuk menampilkan loading indicator
class CategoryLoading extends CategoryState {}

/// State yang menunjukkan daftar kategori berhasil dimuat
/// Properties:
/// - categories: List dari CategoryModel yang berisi data kategori
class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;

  CategoryLoaded({required this.categories});
}

/// State yang menunjukkan operasi berhasil dilakukan
/// Properties:
/// - message: Pesan sukses yang akan ditampilkan ke user
class CategorySuccess extends CategoryState {
  final String message;

  CategorySuccess({required this.message});
}

/// State yang menunjukkan terjadi error
/// Properties:
/// - message: Pesan error yang akan ditampilkan ke user
class CategoryError extends CategoryState {
  final String message;

  CategoryError({required this.message});
}
