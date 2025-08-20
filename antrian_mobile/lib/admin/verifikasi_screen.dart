import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class VerifikasiScreen extends StatefulWidget {
  const VerifikasiScreen({super.key});

  @override
  State<VerifikasiScreen> createState() => _VerifikasiScreenState();
}

class _VerifikasiScreenState extends State<VerifikasiScreen> {
  List<dynamic> pendaftar = [];
  bool isLoading = true;

  // Gunakan 10.0.2.2 untuk emulator Android
   final String baseUrl = "http://localhost:3000/api/antrian"; // Sesuaikan dengan backend

  @override
  void initState() {
    super.initState();
    fetchPendaftar();
  }

  /// Ambil semua data pendaftar dari backend
  Future<void> fetchPendaftar() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseUrl/pendaftar"));

      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            // Filter hanya yang menunggu verifikasi
            pendaftar = (data["data"] as List)
                .where((user) => user['status'] == 'Menunggu Verifikasi')
                .toList();
          });
        } else {
          _showSnackBar("Gagal memuat data", isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Error: $e", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Verifikasi user → simpan ke tabel antrian dengan nomor otomatis
  Future<void> verifikasiUser(int userId) async {
    try {
      final response =
          await http.post(Uri.parse("$baseUrl/verifikasi/$userId"));
      final data = json.decode(response.body);

      if (mounted) {
        if (response.statusCode == 200 && data["success"] == true) {
          _showSnackBar(
              "User diverifikasi! Nomor antrian: ${data['nomor_antrian']}");
          fetchPendaftar(); // Refresh data setelah verifikasi
        } else {
          _showSnackBar(data["message"] ?? "Verifikasi gagal", isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Error: $e", isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Verifikasi Pendaftar",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchPendaftar,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendaftar.isEmpty
              ? _buildEmptyState()
              : AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pendaftar.length,
                    itemBuilder: (context, index) {
                      final user = pendaftar[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildVerificationCard(user),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildVerificationCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user["nama"],
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.credit_card, "NIK", user["nik"]),
            const SizedBox(height: 4),
            _buildInfoRow(
                Icons.work_outline, "Layanan", user["jenis_layanan"]),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Verifikasi Pendaftar"),
                onPressed: () => verifikasiUser(user["id"]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 16),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: GoogleFonts.poppins(color: Colors.grey[700]),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green[200]),
          const SizedBox(height: 20),
          Text(
            "Tidak Ada Verifikasi",
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            "Semua pendaftar sudah diverifikasi.",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}