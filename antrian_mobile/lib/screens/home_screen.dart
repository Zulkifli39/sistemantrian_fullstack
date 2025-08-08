import 'package:flutter/material.dart';
import 'daftarpendaftar_screen.dart';
import 'daftarantrian_screen.dart';
import 'statuslayanan_screen.dart';
import 'admin_login_screen.dart'; // import halaman login admin
import 'antrian_screen.dart'; // import halaman antrian

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sistem Antrian"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DaftarPendaftarScreen(userId: user["id"]),
                  ),
                );
              },
              child: const Text("Daftar Pendaftar"),
            ),
             const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const AntrianScreen()),
);
              },
              child: const Text("Ambil Antrian"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DaftarAntrianScreen(userId: user["id"]),
                  ),
                );
              },
              child: const Text("Daftar Antrian"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StatusLayananScreen(userId: user["id"]),
                  ),
                );
              },
              child: const Text("Status Layanan"),
            ),
            const Divider(height: 40, thickness: 1),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginScreen(),
                  ),
                );
              },
              child: const Text(
                "Login Admin",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
