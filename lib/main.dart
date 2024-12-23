/// Entry point aplikasi dan konfigurasi utama
/// Menginisialisasi Firebase dan mengatur tema global aplikasi

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mob3_uas_klp_02/pages/admin/admin_dashboard.dart';
import 'package:mob3_uas_klp_02/pages/auth/login.dart';
import 'package:mob3_uas_klp_02/pages/auth/register.dart';
import 'package:mob3_uas_klp_02/pages/auth/resetPasword.dart';
import 'package:mob3_uas_klp_02/pages/intro.dart';
import 'package:mob3_uas_klp_02/pages/reconnect.dart';
import 'package:mob3_uas_klp_02/pages/splash.dart';
import 'package:mob3_uas_klp_02/widget/bottom_bar.dart';
import 'firebase_options.dart';

/// Fungsi main untuk inisialisasi dan menjalankan aplikasi
void main() async {
  // Inisialisasi binding Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase dengan konfigurasi platform spesifik
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Jalankan aplikasi
  runApp(const MyApp());
}

/// Widget root aplikasi
/// Mengatur tema dan routing aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Opsi untuk fullscreen mode
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
    //     overlays: [
    //       SystemUiOverlay.bottom,
    //     ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: settingTheme(),
      initialRoute: '/', // Rute awal aplikasi
      // Konfigurasi routing aplikasi
      routes: {
        '/': (context) => const Splash(), // Splash screen
        'intro': (context) => const Intro(), // Intro/onboarding
        'login': (context) => const Login(), // Halaman login
        'register': (context) => const Register(), // Halaman registrasi
        'userPage': (context) => const BottomBar(), // Halaman utama
        'reconnect': (context) => const Reconnect(), // Halaman error koneksi
        'resetPassword': (context) =>
            const ResetPasswordScreen(), // Reset password
        'adminDashboard': (context) => AdminDashboard(),
      },
    );
  }

  /// Konfigurasi tema global aplikasi
  ThemeData settingTheme() {
    return ThemeData(
      useMaterial3: true,
      // Warna utama aplikasi
      primaryColor: const Color.fromARGB(255, 129, 213, 252),
      secondaryHeaderColor: const Color.fromARGB(255, 126, 241, 103),
      highlightColor: Colors.blue, // Warna button
      fontFamily: 'Roboto',

      // Konfigurasi style tombol elevated
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 202, 223, 178),
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 50),
            textStyle: const TextStyle(color: Colors.black)),
      ),

      // Konfigurasi style teks
      primaryTextTheme: const TextTheme(
        // Heading besar (30px)
        titleLarge: TextStyle(
            fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        // Heading medium (21px)
        titleMedium: TextStyle(fontSize: 21, color: Colors.white),
        // Heading kecil (17px)
        titleSmall: TextStyle(
            fontSize: 17, color: Colors.white, fontWeight: FontWeight.normal),
        // Teks display besar (20px)
        displayLarge: TextStyle(fontSize: 20, color: Colors.black87),
        // Teks display medium (17px)
        displayMedium: TextStyle(fontSize: 17, color: Colors.black87),
        // Teks display kecil (15px)
        displaySmall: TextStyle(fontSize: 15, color: Colors.black87),
      ),
    );
  }
}
