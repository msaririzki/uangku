/// Screen untuk menampilkan halaman error saat tidak ada koneksi internet
/// Memberikan opsi untuk mencoba menghubungkan kembali
/// 
/// Fitur:
/// - Pesan error yang informatif
/// - Tombol retry
/// - Ilustrasi visual
/// - Auto sizing untuk berbagai ukuran layar

import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_02/global_variable.dart';
import 'package:mob3_uas_klp_02/widget/elevated_button.dart';

class Reconnect extends StatelessWidget {
  const Reconnect({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Background warna abu-abu
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ilustrasi koneksi terputus
          Image.asset(
            'assets/connected.png',
            width: GlobalVariable.deviceWidth(context) * 0.55,
            height: GlobalVariable.deviceWidth(context) * 0.4,
          ),
          // Pesan error
          Text(
            'Tidak ada koneksi internet. Mohon periksa pengaturan jaringan Anda dan coba lagi.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .displaySmall!
                .copyWith(color: Colors.black26),
          ),
          const SizedBox(height: 18.0),
          // Tombol retry dengan lebar responsif
          SizedBox(
            width: GlobalVariable.deviceWidth(context) * 0.4,
            child: ButtonElevated(
              onPress: () {
                // Coba hubungkan kembali dengan me-refresh halaman utama
                Navigator.pushReplacementNamed(context, 'userPage');
              },
              text: 'Coba Lagi',
            ),
          )
        ],
      ),
    );
  }
}
