/// Model untuk menyimpan data kategori transaksi
/// Digunakan untuk mengelompokkan pemasukan dan pengeluaran
/// 
/// Properties:
/// - uid: ID unik kategori (diisi otomatis saat dibuat)
/// - userId: ID pengguna pemilik kategori
/// - name: Nama kategori (contoh: "Gaji", "Makan", dll)
/// - category: Jenis kategori ("Pemasukan" atau "Pengeluaran")
/// 
/// Batasan:
/// - Setiap user maksimal memiliki 6 kategori per jenis
/// - Nama kategori harus unik per user
/// - Nama kategori tidak boleh kosong
/// 
/// Contoh penggunaan:
/// ```dart
/// final kategori = CategoryModel(
///   name: 'Gaji Bulanan',
///   category: 'Pemasukan'
/// );
/// ```
class CategoryModel {
  // ID unik kategori
  String? uid;
  
  // ID pemilik kategori
  String? userId;
  
  // Data kategori
  String name;         // Nama kategori
  String category;     // Jenis: Pemasukan/Pengeluaran

  CategoryModel({
    this.uid,
    this.userId,
    required this.name,
    required this.category
  });
}