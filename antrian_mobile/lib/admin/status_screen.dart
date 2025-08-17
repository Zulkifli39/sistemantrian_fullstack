import 'package:flutter/material.dart';

class StatusScreen extends StatelessWidget {
  // Contoh data user dan status verifikasi
  final List<Map<String, dynamic>> users = [
    {'id': 1, 'nama': 'Budi', 'status': 'Terverifikasi'},
    {'id': 2, 'nama': 'Siti', 'status': 'Belum Diverifikasi'},
    {'id': 3, 'nama': 'Andi', 'status': 'Terverifikasi'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status Verifikasi User'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(users[index]['nama']),
              subtitle: Text('Status: ${users[index]['status']}'),
              trailing: users[index]['status'] == 'Terverifikasi'
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : Icon(Icons.cancel, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
