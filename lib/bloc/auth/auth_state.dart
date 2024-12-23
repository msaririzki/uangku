part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

/// State awal ketika aplikasi pertama kali dibuka
/// atau ketika BLoC baru diinisialisasi
final class AuthInitial extends AuthState {}

/// State yang menunjukkan proses autentikasi sedang berlangsung
/// Digunakan untuk menampilkan loading indicator
///
/// Contoh penggunaan:
/// ```dart
/// if (state is AuthLoading) {
///   return CircularProgressIndicator();
/// }
/// ```
class AuthLoading extends AuthState {}

/// State yang menunjukkan user berhasil terautentikasi
/// Menyimpan data user yang sedang login
///
/// Properties:
/// - user: Instance dari FirebaseUser yang berisi data user
///
/// Contoh penggunaan:
/// ```dart
/// if (state is Authenticated) {
///   final user = state.user;
///   return Text('Welcome ${user.email}');
/// }
/// ```
class Authenticated extends AuthState {
  final User? user;
  final String role;

  Authenticated(this.user, this.role);
}

/// State yang menunjukkan tidak ada user yang login
/// atau proses logout berhasil
///
/// Contoh penggunaan:
/// ```dart
/// if (state is UnAuthenticated) {
///   return LoginScreen();
/// }
/// ```
class UnAuthenticated extends AuthState {}

/// State yang menunjukkan terjadi error dalam proses autentikasi
/// Menyimpan pesan error yang akan ditampilkan ke user
///
/// Properties:
/// - message: Pesan error yang user-friendly
///
/// Contoh penggunaan:
/// ```dart
/// if (state is AuthenticatedError) {
///   return Text('Error: ${state.message}');
/// }
/// ```
class AuthenticatedError extends AuthState {
  final String message;

  AuthenticatedError({required this.message});
}
