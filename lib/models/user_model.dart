/// Model untuk menyimpan data pengguna aplikasi
/// Digunakan untuk proses autentikasi dan manajemen profil
/// 
/// Properties:
/// - uid: ID unik pengguna (diisi otomatis oleh Firebase Auth)
/// - email: Alamat email pengguna (digunakan untuk login)
/// - password: Password pengguna (hanya digunakan saat registrasi)
/// - phone: Nomor telepon pengguna
/// - name: Nama lengkap pengguna
/// 
/// Contoh penggunaan:
/// ```dart
/// final user = UserModel(
///   email: 'user@example.com',
///   password: 'password123',
///   phone: '08123456789',
///   name: 'John Doe'
/// );
/// ```
class UserModel {
  // ID unik dari Firebase Auth
  String? uid;
  
  // Kredensial login
  String? email;
  String? password;
  
  // Data profil
  String? phone;
  String? name;

  UserModel({
    this.uid,
    this.email, 
    this.password,
    this.phone,
    this.name
  });
}
