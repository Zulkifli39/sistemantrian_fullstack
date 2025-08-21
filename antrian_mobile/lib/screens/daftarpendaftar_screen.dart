import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../providers/antrian_provider.dart'; // Pastikan import ini sesuai dengan lokasi file AntrianProvider

class DaftarPendaftarScreen extends StatefulWidget {
  final int userId;

  const DaftarPendaftarScreen({super.key, required this.userId});

  @override
  State<DaftarPendaftarScreen> createState() => _DaftarPendaftarScreenState();
}

class _DaftarPendaftarScreenState extends State<DaftarPendaftarScreen> {
  bool isLoading = true; // Start with loading true
  final String baseUrl = "http://localhost:3000/api/antrian";

  @override
  void initState() {
    super.initState();
    // Fetch data awal saat inisialisasi
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/pendaftar"));
      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          Provider.of<AntrianProvider>(context, listen: false).setPendaftar(data["data"] ?? []);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal memuat data: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'terverifikasi':
        chipColor = Colors.green;
        statusText = 'Terverifikasi';
        break;
      case 'menunggu verifikasi':
        chipColor = Colors.orange;
        statusText = 'Menunggu';
        break;
      default:
        chipColor = Colors.red;
        statusText = 'Ditolak';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          color: chipColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Daftar Pendaftar",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Consumer<AntrianProvider>(
        builder: (context, antrianProvider, child) {
          final pendaftar = antrianProvider.pendaftar;
          return isLoading
              ? const Center(child: CircularProgressIndicator())
              : pendaftar.isEmpty
                  ? _buildEmptyState()
                  : AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pendaftar.length,
                        itemBuilder: (context, index) {
                          final user = pendaftar[index];
                          print('Item $index - ID: ${user["user_id"]}, Nama: ${user["nama"]}, Status: ${user["status"]}');
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 4,
                                  shadowColor: Colors.black.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.blue.withOpacity(0.1),
                                          child: const Icon(
                                            Icons.person_outline,
                                            color: Colors.blue,
                                            size: 30,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user["nama"] ?? "Nama tidak tersedia",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Layanan: ${user["jenis_layanan"]}",
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _buildStatusChip(user["status"] ?? 'Menunggu Verifikasi'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            "Belum Ada Pendaftar",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Data pendaftar akan muncul di sini.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}