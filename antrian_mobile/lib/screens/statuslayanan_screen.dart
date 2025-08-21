import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class StatusLayananScreen extends StatefulWidget {
  final int userId;

  const StatusLayananScreen({super.key, required this.userId});

  @override
  State<StatusLayananScreen> createState() => _StatusLayananScreenState();
}

class _StatusLayananScreenState extends State<StatusLayananScreen> {
  List<dynamic> layananSelesai = [];
  bool isLoading = true;

  final String baseUrl = "http://localhost:3000/api/antrian";

  @override
  void initState() {
    super.initState();
    fetchLayananSelesai();
  }

  Future<void> fetchLayananSelesai() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/pendaftar"));
      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            layananSelesai = (data["data"] ?? [])
                .where((layanan) =>
                    (layanan["status_layanan"]?.toLowerCase().trim() ?? "") == "selesai" &&
                    layanan["user_id"] == widget.userId)
                .toList();
          });
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Selesai",
        style: GoogleFonts.poppins(
          color: Colors.green,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            "Belum Ada Layanan Selesai",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Layanan yang selesai akan muncul di sini.",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Status Layanan Selesai",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : layananSelesai.isEmpty
              ? _buildEmptyState()
              : AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: layananSelesai.length,
                    itemBuilder: (context, index) {
                      final layanan = layananSelesai[index];
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            layanan["nama"] ?? "Nama tidak tersedia",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "No. Antrian: ${layanan["nomor_antrian"] ?? "Tidak tersedia"}",
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildStatusChip(layanan["status_layanan"] ?? "Selesai"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}