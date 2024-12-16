import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_02/widget/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mob3_uas_klp_02/widget/profile_Page.dart'; // Import halaman ProfilePage

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  String name = '';
  String? selectedAvatar;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? ''; // Default ke string kosong
      selectedAvatar = prefs.getString('selectedAvatar'); // Load avatar yang dipilih
    });
    debugPrint('Selected Avatar: $selectedAvatar'); // Log untuk debugging
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 15.0, right: 15.0, top: 7.0, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // Navigasi ke halaman ProfilePage saat foto profil ditekan
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              ).then((_) => _loadUserData()); // Refresh data setelah kembali dari ProfilePage
            },
            child: Row(
              children: [
                CircleAvatar(
  radius: 20,
  backgroundColor: Colors.grey[300],
  backgroundImage: selectedAvatar != null
      ? AssetImage(selectedAvatar!)
      : null,
  child: selectedAvatar == null
      ? const Icon(Icons.person, size: 20, color: Colors.grey)
      : null,
),
                const SizedBox(width: 10),
                Text(
                  name,
                  style: Theme.of(context).primaryTextTheme.titleSmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              DialogWidget.logout(context);
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
