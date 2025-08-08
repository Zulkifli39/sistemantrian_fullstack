import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: UniqueKey(), // 🔄 Memaksa rebuild saat hot reload
      title: 'Sistem Antrian',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(
        user: {
          "id": 0,
          "nama": "Pengunjung",
          "email": "",
        },
      ), // ✅ Mulai dari Home dengan user dummy
      debugShowCheckedModeBanner: false,
    );
  }
}
