import 'package:flutter/material.dart';

class DaftarPendaftarScreen extends StatelessWidget {
  final int userId;

  const DaftarPendaftarScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Pendaftar")),
      body: Center(
        child: Text(
          "Menampilkan daftar pendaftar untuk User ID: $userId",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
