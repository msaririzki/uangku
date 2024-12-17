// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'category_bloc.dart';

@immutable
sealed class CategoryEvent {}

/// Event untuk mengambil daftar kategori
/// Parameter:
/// - category: Jenis kategori (Pemasukan/Pengeluaran)
class GetCategoryEvent extends CategoryEvent {
  final String category;

  GetCategoryEvent({required this.category});
}

/// Event untuk membuat kategori baru
/// Parameter:
/// - model: Model kategori yang berisi data kategori baru
class CreateCategoryEvent extends CategoryEvent {
  final CategoryModel model;

  CreateCategoryEvent({required this.model});
}

/// Event untuk memperbarui kategori
/// Parameter:
/// - uid: ID kategori yang akan diupdate
/// - name: Nama baru untuk kategori
class UpdateCategoryEvent extends CategoryEvent {
  final String uid;
  final String name;

  UpdateCategoryEvent({required this.uid, required this.name});
}

/// Event untuk menghapus kategori
/// Parameter:
/// - uid: ID kategori yang akan dihapus
/// - category: Jenis kategori (untuk reload data setelah penghapusan)
class DestroyCategoryEvent extends CategoryEvent {
  final String uid;
  final String category;

  DestroyCategoryEvent({
    required this.uid,
    required this.category,
  });
}
