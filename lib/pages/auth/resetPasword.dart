/// Screen untuk mereset password pengguna
/// Memungkinkan pengguna untuk meminta email reset password
/// 
/// Fitur:
/// - Form input email
/// - Validasi email
/// - Pengiriman email reset password
/// - Loading indicator
/// - Error handling

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // Controller untuk input email
  final TextEditingController _emailController = TextEditingController();
  // Instance Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // State loading
  bool _isProcessing = false;
  // Pesan error jika ada
  String _errorMessage = '';

  /// Fungsi untuk mengirim email reset password
  Future<void> _resetPassword() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = ''; // Reset pesan error sebelumnya
    });

    try {
      // Kirim email reset password
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      // Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email untuk reset password telah dikirim!'),
        ),
      );
      // Redirect ke halaman login
      Navigator.of(context).pushReplacementNamed('login');
    } catch (e) {
      // Tangani error
      setState(() {
        _errorMessage = 'Kesalahan: ${e.toString()}';
      });
    } finally {
      // Reset state loading
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          height: MediaQuery.of(context).size.height,
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
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Judul halaman
                Text(
                  'Reset Password',
                  style: Theme.of(context).primaryTextTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                // Deskripsi
                Text(
                  'Masukkan email Anda untuk mereset password.',
                  style: Theme.of(context).primaryTextTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                // Form input email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Masukkan email Anda',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.email),
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 20),
                // Tombol submit dengan loading indicator
                _isProcessing
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Center(
                          child: Text(
                            'Kirim Email Reset',
                            style: Theme.of(context).primaryTextTheme.labelLarge,
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                // Tombol kembali ke login
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Kembali ke Login',
                      style: Theme.of(context).primaryTextTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
