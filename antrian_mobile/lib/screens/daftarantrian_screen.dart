import 'package:flutter/material.dart';

class DaftarAntrianScreen extends StatelessWidget {
  final int userId;

  const DaftarAntrianScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Antrian")),
      body: Center(
        child: Text(
          "Menampilkan daftar antrian untuk User ID: $userId",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
