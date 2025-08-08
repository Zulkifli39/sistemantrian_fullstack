import 'package:flutter/material.dart';

class StatusLayananScreen extends StatelessWidget {
  final int userId;

  const StatusLayananScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Status Layanan")),
      body: Center(
        child: Text(
          "Menampilkan status layanan untuk User ID: $userId",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
