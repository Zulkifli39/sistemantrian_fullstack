import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VerifikasiScreen extends StatefulWidget {
  const VerifikasiScreen({super.key});

  @override
  State<VerifikasiScreen> createState() => _VerifikasiScreenState();
}

class _VerifikasiScreenState extends State<VerifikasiScreen> {
  List<dynamic> pendaftar = [];
  bool isLoading = false;

  final String baseUrl = "http://localhost:3000/api/antrian"; // Sesuaikan dengan backend

  @override
  void initState() {
    super.initState();
    fetchPendaftar();
  }

  /// Ambil semua data pendaftar dari backend
  Future<void> fetchPendaftar() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseUrl/pendaftar"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pendaftar = data["data"];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat data")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Verifikasi user → simpan ke tabel antrian dengan nomor otomatis
  Future<void> verifikasiUser(int userId) async {
    try {
      final response = await http.post(Uri.parse("$baseUrl/verifikasi/$userId"));
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User diverifikasi ✅ Nomor antrian: ${data['nomor_antrian']}")),
        );
        fetchPendaftar(); // Refresh data setelah verifikasi
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Verifikasi gagal")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verifikasi Antrian"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendaftar.isEmpty
              ? const Center(child: Text("Belum ada pendaftar"))
              : ListView.builder(
                  itemCount: pendaftar.length,
                  itemBuilder: (context, index) {
                    final user = pendaftar[index];
                    final nomorAntrian = user["nomor_antrian"];
                    final status = user["status_layanan"];
                    final userStatus = user["status"]; // Status dari tabel users

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      child: ListTile(
                        title: Text(user["nama"]),
                        subtitle: Text(
                          "NIK: ${user["nik"]}\nLayanan: ${user["jenis_layanan"]}\nStatus: ${userStatus ?? 'Menunggu Verifikasi'}",
                        ),
                        trailing: nomorAntrian == null && userStatus != "Terverifikasi"
                            ? ElevatedButton(
                                onPressed: () => verifikasiUser(user["user_id"]),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text("Verifikasi"),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "No: $nomorAntrian",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(status ?? "-"),
                                ],
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}