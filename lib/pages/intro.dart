/// Screen untuk menampilkan halaman intro/onboarding
/// Menampilkan carousel informasi tentang aplikasi untuk pengguna baru
/// 
/// Fitur:
/// - Carousel slide informasi
/// - Indikator halaman (dots)
/// - Tombol navigasi
/// - Background gradient
/// - Animasi transisi

import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_02/widget/elevated_button.dart';
import '../services/intro_service.dart';
import '../global_variable.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  // State untuk tracking posisi halaman
  int locationPage = 0;
  
  // Controller untuk PageView
  PageController _controller = PageController();

  @override
  void initState() {
    // Inisialisasi controller dengan halaman awal
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    // Bersihkan controller saat widget di-dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        // Background gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).secondaryHeaderColor,
            ],
          ),
        ),
        child: Column(
          children: [
            // Carousel content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                itemCount: contents.length,
                // Update indikator saat halaman berubah
                onPageChanged: (int index) {
                  setState(() {
                    locationPage = index;
                  });
                },
                itemBuilder: (BuildContext context, int i) {
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Gambar ilustrasi
                        Image.asset(
                          contents[i].image,
                          width: GlobalVariable.deviceWidth(context) * 0.80,
                          height: GlobalVariable.deviceHeight(context) * 0.50,
                        ),
                        // Judul slide
                        Text(
                            contents[i].title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).primaryTextTheme.titleMedium
                        ),
                        const SizedBox(height: 20),
                        // Deskripsi slide
                        Text(
                          contents[i].text,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).primaryTextTheme.titleSmall,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Indikator halaman (dots)
            buildDot(contents, locationPage),
            const SizedBox(height: 20),
            // Tombol navigasi
            ButtonElevated(
              // Text tombol berubah di halaman terakhir
              text: locationPage == contents.length - 1 ? 'Login' : 'Selanjutnya',
              onPress: () {
                if (locationPage == contents.length - 1) {
                  // Di halaman terakhir, navigasi ke login
                  Navigator.pushNamed(context, 'login');
                } else {
                  // Pindah ke halaman berikutnya
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk menampilkan indikator halaman (dots)
  /// Menampilkan dot untuk setiap halaman dengan highlight untuk halaman aktif
  Widget buildDot(contents, index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        contents.length,
        (int i) => Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 10),
          // Warna berbeda untuk dot aktif
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: index == i ? Colors.white : Colors.white38),
        ),
      ),
    );
  }
}
