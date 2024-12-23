/// File ini berisi implementasi AuthBloc yang menangani seluruh logika autentikasi
/// menggunakan BLoC (Business Logic Component) pattern.
///
/// AuthBloc mengelola:
/// - Login/Logout
/// - Registrasi
/// - Validasi token
/// - Penyimpanan data user
/// - Penanganan error

// Import package yang diperlukan untuk autentikasi dan penyimpanan data
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mob3_uas_klp_02/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// AuthBloc adalah kelas utama yang mengimplementasikan BLoC pattern untuk autentikasi.
/// Kelas ini menangani semua event terkait autentikasi dan mengubah state sesuai hasil prosesnya.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Instance Firebase untuk autentikasi
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Instance Firestore untuk menyimpan data user
  final FirebaseFirestore db = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    /// Handler untuk CheckLoginStatusEvent
    /// Event ini dipanggil saat aplikasi pertama kali dibuka atau perlu memeriksa status login
    on<CheckLoginStatusEvent>((event, emit) async {
      User? user;

      try {
        // Delay 4 detik untuk memberikan waktu loading splash screen
        await Future.delayed(const Duration(seconds: 4), () async {
          // Mengambil data user yang sedang login (jika ada)
          user = _auth.currentUser;
        });

        // Memeriksa apakah token masih valid dan belum expired
        if (await isTokenValid()) {
          if (user != null) {
            // Ambil data user dari Firestore untuk mendapatkan role
            DocumentSnapshot userDoc =
                await db.collection('users').doc(user!.uid).get();
            String role =
                userDoc['role'] ?? 'User'; // Mendefinisikan 'role' di sini

            // User terautentikasi dan token valid
            emit(Authenticated(user, role));
          } else {
            // Tidak ada user yang login
            emit(UnAuthenticated());
          }
        } else {
          // Token tidak valid atau expired, lakukan logout otomatis
          await _auth.signOut();
          emit(UnAuthenticated());
        }
      } catch (e) {
        // Tangani error yang mungkin terjadi
        emit(AuthenticatedError(message: e.toString()));
      }
    });

    /// Handler untuk LoginEvent
    /// Menangani proses login user dengan email dan password
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
            email: event.email.trim(), password: event.password.trim());

        User? user = userCredential.user;

        if (user != null) {
          // Ambil data user dari Firestore untuk mendapatkan role
          DocumentSnapshot userDoc =
              await db.collection('users').doc(user.uid).get();
          String role = userDoc['role'] ??
              'User'; // Default ke 'User' jika tidak ada role

          // Simpan role ke dalam state
          emit(Authenticated(user, role));
        } else {
          emit(UnAuthenticated());
        }
      } catch (e) {
        String errorMessage = 'Error';
        if (e is FirebaseAuthException) {
          errorMessage = validate(e);
        }
        emit(AuthenticatedError(message: errorMessage));
      }
    });

    /// Handler untuk SignupEvent
    /// Menangani proses registrasi user baru
    on<SignupEvent>((event, emit) async {
      // Ubah state menjadi loading selama proses registrasi
      emit(AuthLoading());

      try {
        // Mencoba membuat akun baru di Firebase Auth
        final userCredential = await _auth.createUserWithEmailAndPassword(
            email: event.user.email.toString(),
            password: event.user.password.toString());

        final user = userCredential.user;

        if (user != null) {
          // Registrasi berhasil:
          // 1. Simpan data lengkap user ke Firestore
          try {
            await db.collection("users").doc(user.uid).set({
              'uid': user.uid,
              'email': user.email,
              'phone': event.user.phone.toString(),
              'name': event.user.name.toString(),
              'role': 'User',
              'created_at': DateTime.now()
            });
          } catch (e) {
            emit(AuthenticatedError(
                message: 'Gagal menyimpan data pengguna: ${e.toString()}'));
            return; // Keluar dari fungsi jika terjadi kesalahan
          }

          // 2. Generate token dan simpan data user ke local storage
          await generateToken(user);
          // Mendapatkan role dari Firestore setelah registrasi
          DocumentSnapshot userDoc =
              await db.collection('users').doc(user.uid).get();
          String role =
              userDoc['role'] ?? 'User'; // Mendefinisikan 'role' di sini
          emit(Authenticated(user, role));
        } else {
          // Registrasi gagal
          emit(UnAuthenticated());
        }
      } catch (e) {
        // Tangani error registrasi:
        // - Email sudah terdaftar
        // - Password terlalu lemah
        // - Format email tidak valid
        String errorMessage = 'Error';
        if (e is FirebaseAuthException) {
          errorMessage = validate(e);
        }
        emit(AuthenticatedError(message: errorMessage));
      }
    });

    /// Handler untuk LogoutEvent
    /// Menangani proses logout user
    on<LogoutEvent>((event, emit) async {
      try {
        // Proses logout:
        // 1. Hapus token dan data user dari local storage
        await removeToken();
        // 2. Sign out dari Firebase Auth
        await _auth.signOut();
        emit(UnAuthenticated());
      } catch (e) {
        emit(AuthenticatedError(message: e.toString()));
      }
    });
  }

  /// Fungsi untuk memvalidasi dan menerjemahkan error dari Firebase Auth
  /// Mengubah pesan error default menjadi pesan yang lebih user-friendly
  String validate(FirebaseAuthException e) {
    String errorMessage;

    switch (e.code) {
      // Kelompok error saat login
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        // Menampilkan pesan yang sama untuk semua error kredensial
        // untuk menghindari security breach
        errorMessage = 'Email atau Password salah.';
        break;

      // Kelompok error saat registrasi
      case 'email-already-in-use':
        errorMessage = 'Email sudah terdaftar. Silakan gunakan email lain.';
        break;
      case 'invalid-email':
        errorMessage =
            'Email tidak valid. Silakan periksa kembali format email.';
        break;
      case 'weak-password':
        errorMessage =
            'Password terlalu lemah. Harap gunakan kombinasi yang lebih kuat.';
        break;

      // Kelompok error sistem
      case 'too-many-requests':
        errorMessage = 'Terlalu banyak permintaan. Silakan coba lagi nanti.';
        break;
      case 'network-request-failed':
        errorMessage = 'Periksa koneksi internet Anda.';
        break;
      default:
        errorMessage = 'Terjadi kesalahan: ${e.message}';
        break;
    }

    return errorMessage;
  }

  /// Fungsi untuk menghasilkan dan menyimpan token sesi beserta data user
  /// Token memiliki masa berlaku 14 hari
  Future<void> generateToken(user) async {
    // Inisialisasi SharedPreferences untuk penyimpanan lokal
    final prefs = await SharedPreferences.getInstance();

    // Dapatkan token dari Firebase Auth
    final token = await user.getIdToken();

    // Simpan token dan waktu expired (14 hari dari sekarang)
    await prefs.setString('session_token', token!);
    await prefs.setInt('token_expiry',
        DateTime.now().add(const Duration(days: 14)).millisecondsSinceEpoch);

    // Ambil data lengkap user dari Firestore
    final DocumentSnapshot getUser =
        await db.collection('users').doc(user.uid).get();
    if (getUser.exists) {
      // Siapkan data user untuk disimpan di local storage
      final Map<String, String> userInfo = {
        "uid": getUser['uid'],
        "name": getUser['name'],
        "email": getUser['email'],
        "phone": getUser['phone'],
      };

      // Simpan semua informasi user ke SharedPreferences
      await prefs.setString('uid', userInfo['uid']!);
      await prefs.setString('name', userInfo['name']!);
      await prefs.setString('email', userInfo['email']!);
      await prefs.setString('phone', userInfo['phone']!);
    }
  }

  /// Fungsi untuk memeriksa apakah token masih valid
  /// Returns: true jika token masih valid, false jika sudah expired
  Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    // Ambil waktu expired token
    final expiryTimestamp = prefs.getInt('token_expiry') ?? 0;

    // Bandingkan dengan waktu sekarang
    if (DateTime.now().millisecondsSinceEpoch >= expiryTimestamp) {
      // Token sudah expired, hapus semua data
      await removeToken();
      return false;
    }

    return true;
  }

  /// Fungsi untuk menghapus semua data autentikasi dari local storage
  /// Dipanggil saat logout atau token expired
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Hapus token
    await prefs.remove('session_token');
    await prefs.remove('token_expiry');
    // Hapus data user
    await prefs.remove('uid');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('phone');
  }
}
