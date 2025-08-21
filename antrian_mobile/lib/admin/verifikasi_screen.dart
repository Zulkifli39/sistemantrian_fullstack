// verifikasi_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/antrian_provider.dart';

class VerifikasiScreen extends StatefulWidget {
  const VerifikasiScreen({super.key});

  @override
  State<VerifikasiScreen> createState() => _VerifikasiScreenState();
}

class _VerifikasiScreenState extends State<VerifikasiScreen> {
  bool isLoading = false;

  final String baseUrl = "http://localhost:3000/api/antrian";

  Future<void> fetchPendaftar(BuildContext context) async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseUrl/pendaftar"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Provider.of<AntrianProvider>(context, listen: false).setPendaftar(data["data"]);
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

  Future<void> verifikasiUser(int userId, BuildContext context) async {
    try {
      final response = await http.post(Uri.parse("$baseUrl/verifikasi/$userId"));
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User diverifikasi ✅ Nomor antrian: ${data['nomor_antrian']}")),
        );

        // Perbarui data pendaftar
        Provider.of<AntrianProvider>(context, listen: false).updatePendaftarAfterVerification(
          userId,
          {
            "status": "Terverifikasi",
            "nomor_antrian": data["nomor_antrian"],
            "status_layanan": "Menunggu",
          },
        );
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
  void initState() {
    super.initState();
    fetchPendaftar(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AntrianProvider>(
      builder: (context, antrianProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Verifikasi Antrian"),
            backgroundColor: Colors.blue,
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : antrianProvider.pendaftar.isEmpty
                  ? const Center(child: Text("Belum ada pendaftar"))
                  : ListView.builder(
                      itemCount: antrianProvider.pendaftar.length,
                      itemBuilder: (context, index) {
                        final user = antrianProvider.pendaftar[index];
                        final nomorAntrian = user["nomor_antrian"];
                        final status = user["status_layanan"];
                        final userStatus = user["status"];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          child: ListTile(
                            title: Text(user["nama"]),
                            subtitle: Text(
                              "NIK: ${user["nik"]}\nLayanan: ${user["jenis_layanan"]}\nStatus: ${userStatus ?? 'Menunggu Verifikasi'}",
                            ),
                            trailing: nomorAntrian == null && userStatus != "Terverifikasi"
                                ? ElevatedButton(
                                    onPressed: () => verifikasiUser(user["user_id"], context),
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
      },
    );
  }
}