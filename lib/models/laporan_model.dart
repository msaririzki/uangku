/// Model untuk menyimpan data laporan keuangan
/// 
/// Properties:
/// - uid: ID unik laporan (opsional, diisi saat mengambil data)
/// - userId: ID user pemilik laporan (opsional, diisi otomatis)
/// - keterangan: Catatan tambahan untuk laporan (opsional)
/// - nominal: Jumlah uang (wajib)
/// - categoryTipe: Jenis kategori (Pemasukan/Pengeluaran)
/// - categoryName: Nama kategori yang dipilih (wajib)
/// - tanggal: Tanggal laporan (wajib)
/// - createdAt: Waktu pembuatan laporan (wajib)
class LaporanModel {
  String? uid;
  String? userId;
  String? keterangan;
  int nominal;
  String? categoryTipe;
  String categoryName;
  DateTime tanggal;
  DateTime createdAt;

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
