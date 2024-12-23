import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupervisorDashboard extends StatefulWidget {
  @override
  _SupervisorDashboardState createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  int userCount = 0;
  int onlineUserCount = 0;
  int offlineUserCount = 0;
  int dailyTransactions = 0;
  int weeklyTransactions = 0;
  int monthlyTransactions = 0;

  @override
  void initState() {
    super.initState();
    fetchUserCounts();
    fetchTransactionCounts();
  }

  Future<void> fetchUserCounts() async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userSnapshot = await userCollection.get();

    setState(() {
      userCount = userSnapshot.docs.length;
      onlineUserCount =
          userSnapshot.docs.where((doc) => doc['status'] == 'online').length;
      offlineUserCount = userCount - onlineUserCount; // Hitung pengguna offline
    });
  }

  Future<void> fetchTransactionCounts() async {
    final transactionCollection =
        FirebaseFirestore.instance.collection('transactions');

    // Hitung transaksi untuk 1 hari
    final dailySnapshot = await transactionCollection
        .where('date',
            isGreaterThan: DateTime.now().subtract(Duration(days: 1)))
        .get();
    dailyTransactions = dailySnapshot.docs.length;

    // Hitung transaksi untuk 1 minggu
    final weeklySnapshot = await transactionCollection
        .where('date',
            isGreaterThan: DateTime.now().subtract(Duration(days: 7)))
        .get();
    weeklyTransactions = weeklySnapshot.docs.length;

    // Hitung transaksi untuk 1 bulan
    final monthlySnapshot = await transactionCollection
        .where('date',
            isGreaterThan: DateTime.now().subtract(Duration(days: 30)))
        .get();
    monthlyTransactions = monthlySnapshot.docs.length;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Pengawas'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, 'login');
              } catch (e) {
                print(
                    'Error signing out: $e'); // Menampilkan kesalahan di console
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[200], // Warna latar belakang yang lebih lembut
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Kartu untuk jumlah pengguna
              _buildInfoCard('Jumlah Pengguna', '$userCount', Icons.people, Colors.blueAccent),
              SizedBox(height: 20),
              // Kartu untuk jumlah pengguna online
              _buildInfoCard('Jumlah Pengguna Online', '$onlineUserCount', Icons.online_prediction, Colors.green),
              SizedBox(height: 20),
              // Kartu untuk jumlah pengguna offline
              _buildInfoCard('Jumlah Pengguna Offline', '$offlineUserCount', Icons.offline_bolt, Colors.red),
              SizedBox(height: 20),
              // Kartu untuk transaksi
              _buildTransactionCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 40, color: color),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text(value, style: TextStyle(fontSize: 36, color: color)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaksi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Hari Ini: $dailyTransactions', style: TextStyle(fontSize: 18)),
            Text('Minggu Ini: $weeklyTransactions', style: TextStyle(fontSize: 18)),
            Text('Bulan Ini: $monthlyTransactions', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
