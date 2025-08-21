import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart'; // Impor SplashScreen
import 'screens/home_screen.dart';   // Impor HomeScreen
import 'providers/antrian_provider.dart'; // Impor AntrianProvider

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AntrianProvider()),
      ],
      child: MaterialApp(
        key: UniqueKey(), // Memaksa rebuild saat hot reload
        title: 'Sistem Antrian',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashScreen(
          user: {
            "id": 0,
            "nama": "Pengunjung",
            "email": "",
          },
        ), // Mulai dari SplashScreen dengan data user dummy
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}