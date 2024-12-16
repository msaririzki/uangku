import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;
  File? _profileImage;

  List<String> _avatarList = [
    'assets/apatar1.png',
    'assets/apatar2.jpg',
    'assets/apatar3.jpg',
    'assets/apatar4.png',
    'assets/apatar5.png',
    // Tambahkan lebih banyak avatar sesuai kebutuhan
  ];

  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            _phoneController.text = doc['phone'] ?? '';
            _gender = doc['gender'];
            _birthDate = (doc['birthDate'] as Timestamp?)?.toDate();
            _selectedAvatar = doc['avatar'];
            // Jika ada field lain, tambahkan di sini
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat memuat data: $e')),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final localImage = File('${directory.path}/profile_image.jpg');

        // Salin file ke lokasi lokal
        await File(pickedFile.path).copy(localImage.path);

        // Set gambar ke state
        setState(() {
          _profileImage = localImage;
        });

        // Beri feedback kepada pengguna
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Foto profil berhasil disimpan secara lokal!')),
        );
      } else {
        // Jika pengguna membatalkan pemilihan gambar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada gambar yang dipilih.')),
        );
      }
    } catch (e) {
      // Tangani error dengan memberikan feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          height: MediaQuery.of(context).size.height,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _selectedAvatar != null
                    ? AssetImage(_selectedAvatar!)
                    : null,
                child: _selectedAvatar == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey[800],
                      )
                    : null,
              ),
              const SizedBox(height: 10),
              // Dropdown untuk memilih avatar
              DropdownButtonFormField<String>(
                value: _selectedAvatar,
                decoration: InputDecoration(
                  labelText: 'Pilih Avatar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _avatarList.map((avatar) {
                  return DropdownMenuItem(
                    value: avatar,
                    child: Row(
                      children: [
                        Image.asset(avatar, width: 40, height: 40),
                        const SizedBox(width: 10),
                        Text('Avatar ${_avatarList.indexOf(avatar) + 1}'),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAvatar = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Nama Pengguna',
                style: Theme.of(context).primaryTextTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Nomor HP',
                  hintText: 'Masukkan nomor HP Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  hintText: 'Masukkan password baru',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  labelText: 'Jenis Kelamin',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 'L', child: Text('Laki-Laki')),
                  DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _birthDate == null
                            ? 'Pilih Tanggal Lahir'
                            : '${_birthDate!.day}-${_birthDate!.month}-${_birthDate!.year}',
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  // Tambahkan logika untuk menyimpan perubahan
                  try {
                    // Ambil UID pengguna yang sedang login
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      // Update data pengguna di Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({
                        'phone': _phoneController.text,
                        'gender': _gender,
                        'birthDate': _birthDate,
                        'avatar': _selectedAvatar ?? '',
                        // Tambahkan field lain yang ingin disimpan
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Perubahan berhasil disimpan!')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Terjadi kesalahan: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Center(
                  child: Text(
                    'Simpan Perubahan',
                    style: Theme.of(context).primaryTextTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
