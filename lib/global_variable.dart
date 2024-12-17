import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GlobalVariable {
  // Mengambil lebar perangkat dari konteks yang diberikan
  static double deviceWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  // Mengambil tinggi perangkat dari konteks yang diberikan
  static double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Mengonversi angka menjadi format mata uang Rupiah
  static String convertToRupiah(dynamic number) {
    // Membuat formatter untuk mata uang dengan locale Indonesia
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id', // Menggunakan locale Indonesia
      symbol: 'Rp ', // Simbol mata uang
      decimalDigits: 0, // Tidak menampilkan desimal
    );

    // Mengembalikan angka yang telah diformat
    return currencyFormatter.format(number);
  }
}
