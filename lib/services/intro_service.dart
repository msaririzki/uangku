/// Model untuk data konten intro/onboarding
/// Berisi informasi yang ditampilkan pada setiap slide intro
class Intro {
  final String title;    // Judul slide
  final String image;    // Path gambar ilustrasi
  final String text;     // Deskripsi/teks penjelasan

  Intro({
    required this.title,
    required this.image,
    required this.text,
  });
}

/// List konten yang akan ditampilkan pada intro screen
/// Setiap item berisi informasi untuk satu slide
List<Intro> contents = [
  // Slide 1: Monitoring keuangan
  Intro(
    title: 'Pantau Keuangan Anda Secara Real-Time',
    image: 'assets/intro1.png',
    text: 'Lihat kesehatan finansial Anda kapan saja. Pantau pengeluaran dan pemasukan dengan cepat dan akurat.',
  ),
  // Slide 2: Pencatatan transaksi
  Intro(
    title: 'Pencatatan Transaksi Mudah Dan Cepat',
    image: 'assets/intro2.png',
    text: 'Mudah mencatat transaksi dan melihat laporan keuangan Anda. Pastikan tidak ada detail yang terlewat.',
  ),
  // Slide 3: Laporan instan
  Intro(
    title: 'Lihat Laporan Keuangan Anda Secara Instan',
    image: 'assets/intro3.png',
    text: 'Mudah mencatat transaksi dan melihat laporan keuangan Anda. Pastikan tidak ada detail yang terlewat.',
  ),
];
