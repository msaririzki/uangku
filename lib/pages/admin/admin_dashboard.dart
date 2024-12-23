import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int userCount = 0;
  int supervisorCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserCounts();
  }

  Future<void> fetchUserCounts() async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userSnapshot =
        await userCollection.where('role', isEqualTo: 'User').get();
    final supervisorSnapshot =
        await userCollection.where('role', isEqualTo: 'Supervisor').get();

    setState(() {
      userCount = userSnapshot.docs.length;
      supervisorCount = supervisorSnapshot.docs.length;
    });
  }

  void createSupervisorAccount(
      String email, String password, String name) async {
    try {
      // Buat akun dengan Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan data pengguna ke Firestore dengan role 'Supervisor'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'name': name,
        'role': 'Supervisor', // Role diatur sebagai 'Supervisor'
        'status': 'offline', // Status default
      });

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Akun pengawas berhasil dibuat')));
    } catch (e) {
      // Tangani error
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal membuat akun: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(
                  context, 'login'); // Ganti dengan rute login Anda
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Jumlah Pengguna Biasa: $userCount'),
            Text('Jumlah Pengawas: $supervisorCount'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Tampilkan dialog untuk membuat akun pengawas
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Buat Akun Pengawas'),
                      content: CreateSupervisorForm(
                          onCreate: createSupervisorAccount),
                    );
                  },
                );
              },
              child: Text('Buat Akun Pengawas'),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateSupervisorForm extends StatefulWidget {
  final Function(String email, String password, String name) onCreate;

  const CreateSupervisorForm({Key? key, required this.onCreate})
      : super(key: key);

  @override
  _CreateSupervisorFormState createState() => _CreateSupervisorFormState();
}

class _CreateSupervisorFormState extends State<CreateSupervisorForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harap masukkan email';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harap masukkan password';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nama'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harap masukkan nama';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onCreate(
                  _emailController.text,
                  _passwordController.text,
                  _nameController.text,
                );
                Navigator.of(context).pop(); // Tutup dialog
              }
            },
            child: Text('Buat Akun'),
          ),
        ],
      ),
    );
  }
}
