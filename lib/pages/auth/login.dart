/// Screen untuk login pengguna
/// Menggunakan BLoC pattern untuk manajemen state
///
/// Fitur:
/// - Form login (email & password)
/// - Validasi input
/// - Toggle visibility password
/// - Loading state
/// - Error handling
/// - Navigasi ke register dan reset password

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mob3_uas_klp_02/bloc/auth/auth_bloc.dart';
import 'package:mob3_uas_klp_02/widget/elevated_button.dart';
import 'package:mob3_uas_klp_02/widget/text_field.dart';
import '../../global_variable.dart';

/// Widget provider untuk AuthBloc
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: const LoginView(),
    );
  }
}

/// Widget utama untuk tampilan login
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // State untuk toggle password visibility
  bool _obscureText = true;
  // Key untuk form validation
  final _formKey = GlobalKey<FormState>();
  // Controller untuk input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void dispose() {
    // Bersihkan controller saat widget di-dispose
    _emailController.dispose();
    _passController.dispose();
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
            SnackBar(content: Text('Gagal Login: ${state.message}')),
          );
          _passController.clear();
        } else if (state is Authenticated) {
          // Tampilkan success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Berhasil')),
          );
        }
      },
      // Builder untuk UI
      builder: (context, state) {
        // Redirect ke home jika authenticated
        if (state is Authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Redirect berdasarkan role
            if (state.role == 'Admin') {
              Navigator.pushNamedAndRemoveUntil(
                  context, 'adminDashboard', (Route<dynamic> route) => false);
            } else if (state.role == 'Supervisor') {
              Navigator.pushNamedAndRemoveUntil(context, 'supervisorDashboard',
                  (Route<dynamic> route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, 'userPage', (Route<dynamic> route) => false);
            }
          });
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
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
                        const SizedBox(height: 20.0),
                        // Logo/Gambar login
                        Center(
                          child: Image.asset(
                            'assets/login.png',
                            width: GlobalVariable.deviceWidth(context) * 0.5,
                            height: GlobalVariable.deviceWidth(context) * 0.5,
                          ),
                        ),
                        // Judul form
                        Text(
                          'Form Login',
                          style: Theme.of(context).primaryTextTheme.titleLarge,
                        ),
                        // Deskripsi
                        Text(
                          'Lengkapi form login untuk bisa menggunakan aplikasi.',
                          style: Theme.of(context).primaryTextTheme.titleSmall,
                        ),
                        const SizedBox(height: 20),
                        // Form input email
                        FormText(
                          labelText: "Email",
                          hintText: "Masukkan Email anda",
                          controller: _emailController,
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
                        const SizedBox(height: 10),
                        // Link reset password
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'resetPassword');
                          },
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Tombol login
                        ButtonElevated(
                          onPress: state is AuthLoading
                              ? () {} // Disabled saat loading
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    authBloc.add(LoginEvent(
                                      email: _emailController.text,
                                      password: _passController.text,
                                    ));
                                  }
                                },
                          text: state is AuthLoading ? 'Loading' : 'Login',
                          styleText:
                              Theme.of(context).primaryTextTheme.displayMedium,
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Link ke halaman register
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun?',
                          style: Theme.of(context).primaryTextTheme.titleSmall,
                        ),
                        const SizedBox(width: 7),
                        InkWell(
                          onTap: () =>
                              {Navigator.pushNamed(context, 'register')},
                          child: Text(
                            'Daftar Akun',
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
