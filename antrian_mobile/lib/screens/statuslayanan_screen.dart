import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../providers/antrian_provider.dart';
import 'home_screen.dart';
import 'admin_login_screen.dart';

class StatusLayananScreen extends StatefulWidget {
  final int userId;

  const StatusLayananScreen({super.key, required this.userId});

  @override
  State<StatusLayananScreen> createState() => _StatusLayananScreenState();
}

class _StatusLayananScreenState extends State<StatusLayananScreen> {
  bool isLoading = true;
  final String baseUrl = "http://localhost:3000/api/antrian";

  int _bottomIndex = 0; // ✅ tambahkan state untuk bottom nav

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/pendaftar"));
      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final list = (data["data"] ?? []) as List<dynamic>;
          Provider.of<AntrianProvider>(context, listen: false).setPendaftar(list);
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
      case 'selesai':
        chipColor = Colors.green;
        statusText = 'Selesai';
        break;
      case 'terverifikasi':
        chipColor = Colors.blue;
        statusText = 'Terverifikasi';
        break;
      case 'menunggu':
        chipColor = Colors.orange;
        statusText = 'Menunggu';
        break;
      case 'ditolak':
        chipColor = Colors.red;
        statusText = 'Ditolak';
        break;
      default:
        chipColor = Colors.grey;
        statusText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          color: chipColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimary = Color(0xFF2563EB);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false, // hilangkan back icon
        title: Text(
          "Pendaftar Selesai",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<AntrianProvider>(
          builder: (context, antrianProvider, child) {
            final pendaftarSelesai = antrianProvider.pendaftar.where((user) {
              final status = (user["status_layanan"] ?? user["status"] ?? "")
                  .toString()
                  .toLowerCase();
              return status == "selesai";
            }).toList();

            return isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : pendaftarSelesai.isEmpty
                    ? _buildEmptyState()
                    : AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 100, 12, 20),
                          itemCount: pendaftarSelesai.length,
                          itemBuilder: (context, index) {
                            final user = pendaftarSelesai[index] as Map<String, dynamic>;
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 300),
                              child: SlideAnimation(
                                verticalOffset: 40.0,
                                child: FadeInAnimation(
                                  child: Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: Colors.white,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: kPrimary.withOpacity(0.15),
                                        child: const Icon(
                                          Icons.check_circle_outline,
                                          color: kPrimary,
                                          size: 24,
                                        ),
                                      ),
                                      title: Text(
                                        user["nama"] ?? "Nama tidak tersedia",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "Layanan: ${user["jenis_layanan"] ?? '-'}",
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      trailing: _buildStatusChip("Selesai"),
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
      ),
      // ✅ FOOTER NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(user: {"id": 0}),
              ),
            );
          } else if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminLoginScreen()), // Changed from LoginAdminScreen
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kPrimary,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.login_rounded), label: "Login Admin"),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 90, color: Colors.white70),
          const SizedBox(height: 16),
          Text(
            "Belum Ada Data Selesai",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Pendaftar dengan status 'Selesai' akan muncul di sini.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
