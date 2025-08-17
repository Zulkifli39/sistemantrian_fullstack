import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../admin/dashboard_screen.dart'; // Impor DashboardScreen
import '../services/auth_service.dart'; // Pastikan file AuthService diimpor

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> loginAdmin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await AuthService.login(
        emailController.text,
        passwordController.text,
      );

      print("Login Result: $result"); // Debug untuk memeriksa isi result

      if (result["success"] == true) {
        // Ambil data admin dari respons
        final adminData = result["user"];
        print("Admin Data: $adminData"); // Debug untuk memeriksa data admin
        if (adminData == null || adminData.isEmpty) {
          setState(() {
            errorMessage = "Data admin tidak valid";
          });
          return;
        }
        // Navigasi langsung ke DashboardScreen dengan data admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(admin: adminData),
          ),
        );
      } else {
        setState(() {
          errorMessage = result["message"];
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Terjadi kesalahan: $e";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Admin")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : loginAdmin,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}