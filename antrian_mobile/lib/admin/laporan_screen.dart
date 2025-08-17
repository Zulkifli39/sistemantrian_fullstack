import 'package:flutter/material.dart';

class LaporanScreen extends StatelessWidget {
  // Contoh data user dan status verifikasi
  final List<Map<String, dynamic>> users = [
    {'id': 1, 'nama': 'Budi', 'status': 'Terverifikasi'},
    {'id': 2, 'nama': 'Siti', 'status': 'Belum Diverifikasi'},
    {'id': 3, 'nama': 'Andi', 'status': 'Terverifikasi'},
    {'id': 4, 'nama': 'Rina', 'status': 'Belum Diverifikasi'},
  ];

  @override
  Widget build(BuildContext context) {
    int terverifikasi = users.where((u) => u['status'] == 'Terverifikasi').length;
    int belumVerifikasi = users.where((u) => u['status'] == 'Belum Diverifikasi').length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Verifikasi User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total User: ${users.length}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Terverifikasi: $terverifikasi', style: TextStyle(fontSize: 18, color: Colors.green)),
            SizedBox(height: 8),
            Text('Belum Diverifikasi: $belumVerifikasi', style: TextStyle(fontSize: 18, color: Colors.red)),
            SizedBox(height: 24),
            Text('Detail User:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(users[index]['nama']),
                    subtitle: Text('Status: ${users[index]['status']}'),
                    trailing: users[index]['status'] == 'Terverifikasi'
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.cancel, color: Colors.red),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}