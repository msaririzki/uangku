/// Screen untuk menampilkan splash screen saat aplikasi pertama dibuka
/// Melakukan pengecekan status login dan mengarahkan ke halaman yang sesuai
/// 
/// Fitur:
/// - Pengecekan status autentikasi
/// - Loading animation
/// - Auto redirect
/// - Background gradient
/// - Logo aplikasi

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mob3_uas_klp_02/bloc/auth/auth_bloc.dart';
import 'package:mob3_uas_klp_02/global_variable.dart';

/// Widget provider untuk AuthBloc
/// Menginisialisasi BLoC dan memulai pengecekan status login
class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Inisialisasi AuthBloc dan trigger pengecekan status
      create: (context) => AuthBloc()..add(CheckLoginStatusEvent()),
      child: const SplashView(),
    );
  }
}

/// Widget utama untuk tampilan splash screen
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // Handler untuk state changes
      listener: (context, state) {
        if (state is Authenticated) {
          // Jika terautentikasi, arahkan ke halaman utama
          Navigator.pushReplacementNamed(context, 'userPage');
        } else if (state is UnAuthenticated) {
          // Jika tidak terautentikasi, arahkan ke intro
          Navigator.pushReplacementNamed(context, 'intro');
        }
      },
      child: Scaffold(
        body: Container(
          // Padding untuk logo
          padding: EdgeInsets.symmetric(
              horizontal: GlobalVariable.deviceWidth(context) * 0.1),
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
          // Konten splash screen
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo aplikasi
              Image.asset(
                'assets/logo.png',
                width: GlobalVariable.deviceWidth(context) * 0.80,
                height: GlobalVariable.deviceHeight(context) * 0.50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
