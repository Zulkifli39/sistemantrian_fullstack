import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart'; // Import HomeScreen dengan benar

class SplashScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const SplashScreen({super.key, required this.user});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Navigasi ke HomeScreen setelah penundaan
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(user: widget.user)),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value * 2 * 3.14159,
                  child: Image.network(
                    'https://drive.google.com/uc?export=download&id=1gEY0MmH-Vbab7pBLYkBTVvhOC9zNvHNI', // Ganti dengan URL gambar Anda
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Gambar tidak ditemukan');
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return CircularProgressIndicator(
                        value: loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Sistem Antrian',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 10),
            const Text(
              'BPKAD KOTA PALOPO | 2025',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}