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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Kartu untuk jumlah pengguna
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Jumlah Pengguna',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('$userCount',
                          style: TextStyle(
                              fontSize: 36, color: Colors.blueAccent)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Kartu untuk jumlah pengguna online
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Jumlah Pengguna Online',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('$onlineUserCount',
                          style: TextStyle(fontSize: 36, color: Colors.green)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Kartu untuk jumlah pengguna offline
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Jumlah Pengguna Offline',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('$offlineUserCount',
                          style: TextStyle(fontSize: 36, color: Colors.red)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Kartu untuk transaksi
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Transaksi',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Hari Ini: $dailyTransactions',
                          style: TextStyle(fontSize: 18)),
                      Text('Minggu Ini: $weeklyTransactions',
                          style: TextStyle(fontSize: 18)),
                      Text('Bulan Ini: $monthlyTransactions',
                          style: TextStyle(fontSize: 18)),
                    ],
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
