import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/antrian_provider.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool isLoading = false;

  final String baseUrl = "http://localhost:3000/api/antrian";

  Future<void> fetchAntrian(BuildContext context) async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseUrl/daftar-antrian"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Provider.of<AntrianProvider>(context, listen: false)
            .setAntrian(data["data"] ?? []);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: ${response.statusCode}")),
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

  Future<void> updateStatus(String id, BuildContext context) async {
    try {
      final response =
          await http.put(Uri.parse("$baseUrl/update-status/$id"),
              headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );
        Provider.of<AntrianProvider>(context, listen: false)
            .updateAntrianStatus(id, "Selesai");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memperbarui status")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> deleteAntrian(String id, BuildContext context) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/delete/$id"),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );
        Provider.of<AntrianProvider>(context, listen: false).deleteAntrian(id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus antrian")),
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
    fetchAntrian(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AntrianProvider>(
      builder: (context, antrianProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            automaticallyImplyLeading: false, // Remove back button
            backgroundColor: Colors.blue[700],
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            title: Text(
              "Status Antrian",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : antrianProvider.antrian.isEmpty
                  ? Center(
                      child: Text("Belum ada antrian",
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.grey[600])),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: antrianProvider.antrian.length,
                      itemBuilder: (context, index) {
                        final item = antrianProvider.antrian[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3))
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Informasi utama
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item["nama"] ?? "Nama tidak tersedia",
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16)),
                                    const SizedBox(height: 6),
                                    Chip(
                                      label: Text(
                                        "No: ${item["nomor_antrian"]}",
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700]),
                                      ),
                                      backgroundColor: Colors.blue[50],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Status: ${item["status_layanan"]}",
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),

                              // Aksi
                              Column(
                                children: [
                                  if (item["status_layanan"] != "Selesai")
                                    IconButton(
                                      tooltip: "Tandai selesai",
                                      onPressed: () => updateStatus(
                                          item["id"].toString(), context),
                                      icon: const Icon(Icons.check_circle,
                                          color: Colors.green),
                                    ),
                                  if (item["status_layanan"] == "Selesai")
                                    IconButton(
                                      tooltip: "Hapus antrian",
                                      onPressed: () => deleteAntrian(
                                          item["id"].toString(), context),
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                    ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
