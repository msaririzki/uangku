/// Screen untuk registrasi pengguna baru
/// Menggunakan BLoC pattern untuk manajemen state
/// 
/// Fitur:
/// - Form registrasi (email, nama, password)
/// - Validasi input
/// - Toggle visibility password
/// - Loading state
/// - Error handling
/// - Navigasi ke login

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mob3_uas_klp_02/bloc/auth/auth_bloc.dart';
import 'package:mob3_uas_klp_02/global_variable.dart';
import 'package:mob3_uas_klp_02/models/user_model.dart';
import 'package:mob3_uas_klp_02/widget/elevated_button.dart';
import 'package:mob3_uas_klp_02/widget/text_field.dart';

/// Widget provider untuk AuthBloc
class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(),
      child: const RegisterView(),
    );
  }
}

/// Widget utama untuk tampilan registrasi
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // State untuk toggle password visibility
  bool _obscureText = true;
  
  // Key untuk form validation
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    // Bersihkan controller saat widget di-dispose
    _emailController.dispose();
    _passController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    
    return BlocConsumer<AuthBloc, AuthState>(
      // Handler untuk state changes
      listener: (context, state) {
        if (state is AuthenticatedError) {
          // Tampilkan error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal Daftar : ${state.message}')),
          );
          _passController.clear();
        } else if (state is Authenticated) {
          // Tampilkan success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Daftar Akun Berhasil, Silahkan login')),
          );
        }
      },
      // Builder untuk UI
      builder: (context, state) {
        // Redirect ke login jika registrasi berhasil
        if (state is Authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
                context, 'loginPage', (Route<dynamic> route) => false);
          });
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: GlobalVariable.deviceHeight(context),
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
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15.0),
                        // Logo/Gambar register
                        Center(
                          child: Image.asset(
                            'assets/register.png',
                            width: GlobalVariable.deviceWidth(context) * 0.5,
                            height: GlobalVariable.deviceWidth(context) * 0.5,
                          ),
                        ),
                        // Judul form
                        Text(
                          'Daftar Akun',
                          style: Theme.of(context).primaryTextTheme.titleLarge,
                        ),
                        // Deskripsi
                        Text(
                          'Daftar akun untuk bisa login ke aplikasi, lengkapi semua form tersebut.',
                          style: Theme.of(context).primaryTextTheme.titleSmall,
                        ),
                        const SizedBox(height: 20),
                        // Form input email
                        FormText(
                          labelText: "Email",
                          hintText: "Masukkan Email anda",
                          controller: _emailController,
                          prefixIcon: const Icon(Icons.email),
                          backgroundColor: Colors.white,
                          borderFocusColor: Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        // Form input nama
                        FormText(
                          labelText: "Nama",
                          hintText: "Masukkan nama anda",
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.person),
                          backgroundColor: Colors.white,
                          borderFocusColor: Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        // Form input password
                        FormText(
                          labelText: "Password",
                          hintText: "Masukkan password anda",
                          controller: _passController,
                          inputActionDone: true,
                          textKapital: false,
                          prefixIcon: const Icon(Icons.password),
                          backgroundColor: Colors.white,
                          borderFocusColor: Colors.blue,
                          obscureText: _obscureText,
                          // Toggle password visibility
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            child: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Tombol register
                        ButtonElevated(
                          onPress: () {
                            if (_formKey.currentState!.validate()) {
                              // Buat model user dari input
                              UserModel user = UserModel(
                                email: _emailController.text,
                                name: _nameController.text,
                                password: _passController.text,
                              );
                              // Trigger event registrasi
                              authBloc.add(SignupEvent(user: user));
                            }
                          },
                          text: state is AuthLoading ? 'Loading' : 'Daftar',
                          styleText:
                              Theme.of(context).primaryTextTheme.displayMedium,
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Link ke halaman login
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun?',
                          style: Theme.of(context).primaryTextTheme.titleSmall,
                        ),
                        const SizedBox(width: 7),
                        InkWell(
                          onTap: () => {Navigator.pop(context)},
                          child: Text(
                            'Login Akun',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleSmall!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}