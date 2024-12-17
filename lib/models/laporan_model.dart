/// Model untuk menyimpan data laporan keuangan (transaksi)
/// Digunakan untuk mencatat setiap transaksi pemasukan atau pengeluaran
/// 
/// Properties:
/// - uid: ID unik laporan (diisi otomatis saat dibuat di Firestore)
/// - userId: ID pengguna pemilik laporan (diambil dari auth state)
/// - keterangan: Catatan/deskripsi tambahan untuk transaksi (opsional)
/// - nominal: Jumlah uang dalam transaksi (wajib, dalam Rupiah)
/// - categoryTipe: Jenis kategori ("Pemasukan" atau "Pengeluaran")
/// - categoryName: Nama kategori yang dipilih (wajib, harus ada di daftar kategori)
/// - tanggal: Tanggal transaksi dilakukan (wajib)
/// - createdAt: Timestamp pembuatan laporan (diisi otomatis)
/// 
/// Validasi:
/// - nominal harus lebih dari 0
/// - categoryName tidak boleh kosong
/// - tanggal tidak boleh kosong
/// 
/// Contoh penggunaan:
/// ```dart
/// final laporan = LaporanModel(
///   nominal: 1000000,
///   categoryName: 'Gaji',
///   tanggal: DateTime.now(),
///   createdAt: DateTime.now(),
///   keterangan: 'Gaji bulan Januari'
/// );
/// ```
/// 
/// Penggunaan dalam Firestore:
/// ```dart
/// await db.collection("laporan").doc(generateUid).set({
///   "uid": generateUid,
///   "userId": userId,
///   "nominal": laporan.nominal,
///   "categoryName": laporan.categoryName,
///   "tanggal": laporan.tanggal,
///   "createdAt": laporan.createdAt,
///   "keterangan": laporan.keterangan ?? '',
///   "categoryTipe": categoryTipe
/// });
/// ```
class LaporanModel {
  // ID dan referensi
  String? uid;           // ID unik laporan
  String? userId;        // ID pemilik laporan
  
  // Data transaksi
  String? keterangan;    // Deskripsi tambahan (opsional)
  int nominal;           // Jumlah uang (dalam Rupiah)
  
  // Kategori
  String? categoryTipe;  // Jenis: Pemasukan/Pengeluaran
  String categoryName;   // Nama kategori yang dipilih
  
  // Waktu
  DateTime tanggal;      // Tanggal transaksi
  DateTime createdAt;    // Waktu pembuatan laporan

  LaporanModel({
    this.uid,
    this.userId,
    this.keterangan,
    this.categoryTipe,
    required this.nominal,
    required this.categoryName,
    required this.tanggal,
    required this.createdAt,
  });
}
