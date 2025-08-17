import 'package:flutter/material.dart';
import 'verifikasi_screen.dart';
import 'status_screen.dart';
import 'laporan_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> admin;

  const DashboardScreen({super.key, required this.admin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selamat datang, ${admin['nama']}",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Tombol Menu
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifikasiScreen(),
                  ),
                );
              },
              child: const Text("Verifikasi Antrian"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatusScreen(),
                  ),
                );
              },
              child: const Text("Status Antrian"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LaporanScreen(),
                  ),
                );
              },
              child: const Text("Laporan Antrian"),
            ),
          ],
        ),
      ),
    );
  }
}
