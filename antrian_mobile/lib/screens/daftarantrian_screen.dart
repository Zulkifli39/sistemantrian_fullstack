import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../providers/antrian_provider.dart';
import 'home_screen.dart';
import 'admin_login_screen.dart';

class DaftarAntrianScreen extends StatefulWidget {
  final int userId;

  const DaftarAntrianScreen({super.key, required this.userId});

  @override
  State<DaftarAntrianScreen> createState() => _DaftarAntrianScreenState();
}

class _DaftarAntrianScreenState extends State<DaftarAntrianScreen> {
  bool isLoading = true;
  final String baseUrl = "http://localhost:3000/api/antrian";
  int _bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchAntrianUser();
  }

  Future<void> _fetchAntrianUser() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/pendaftar"));
      
      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          List<dynamic> allData = data["data"] ?? [];
          
          // Filter data berdasarkan user_id dan status verifikasi
          List<dynamic> userAntrian = allData.where((item) {
            var userId1 = item["user_id"];
            var userId2 = item["id"]; 
            var userId3 = item["userId"];
            
            bool isUserMatch = (userId1 == widget.userId) || 
                              (userId2 == widget.userId) || 
                              (userId3 == widget.userId);
                              
            bool isVerified = item["status"]?.toString().toLowerCase() == 'terverifikasi';
            bool hasNomorAntrian = item["nomor_antrian"] != null && 
                                  item["nomor_antrian"].toString().isNotEmpty && 
                                  item["nomor_antrian"].toString() != "null";
            
            return isUserMatch && isVerified && hasNomorAntrian;
          }).toList();
          
          // Jika tidak ada data yang cocok, tampilkan semua data terverifikasi (untuk debugging)
          if (userAntrian.isEmpty) {
            List<dynamic> verifiedData = allData.where((item) {
              bool isVerified = item["status"]?.toString().toLowerCase() == 'terverifikasi';
              bool hasNomorAntrian = item["nomor_antrian"] != null && 
                                    item["nomor_antrian"].toString().isNotEmpty && 
                                    item["nomor_antrian"].toString() != "null";
              return isVerified && hasNomorAntrian;
            }).toList();
            
            if (verifiedData.isNotEmpty) {
              userAntrian = verifiedData;
            }
          }
          
          Provider.of<AntrianProvider>(context, listen: false)
              .setAntrian(userAntrian);
              
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Gagal memuat data: ${response.statusCode}"),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            duration: Duration(seconds: 3),
          ),
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
      case 'dipanggil':
        chipColor = Colors.green;
        statusText = 'Dipanggil';
        break;
      case 'menunggu':
        chipColor = Colors.orange;
        statusText = 'Menunggu';
        break;
      case 'selesai':
        chipColor = Colors.blue;
        statusText = 'Selesai';
        break;
      case 'terverifikasi':
        chipColor = Colors.green;
        statusText = 'Terverifikasi';
        break;
      case 'menunggu verifikasi':
        chipColor = Colors.orange;
        statusText = 'Menunggu Verifikasi';
        break;
      default:
        chipColor = Colors.red;
        statusText = status.isEmpty ? 'Menunggu' : status;
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
        automaticallyImplyLeading: false,
        title: Text(
          "Daftar Antrian ",
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
            final daftarAntrian = antrianProvider.antrian;
            
            return isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : daftarAntrian.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchAntrianUser,
                        child: AnimationLimiter(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 100, 12, 80),
                            itemCount: daftarAntrian.length,
                            itemBuilder: (context, index) {
                              final item = daftarAntrian[index];
                              
                              String nama = item["nama"]?.toString() ?? "Nama tidak tersedia";
                              String jenisLayanan = item["jenis_layanan"]?.toString() ?? "-";
                              String nik = item["nik"]?.toString() ?? "-";
                              String nomorAntrian = item["nomor_antrian"]?.toString() ?? "-";
                              String status = item["status"]?.toString() ?? "";
                              String statusLayanan = item["status_layanan"]?.toString() ?? "";
                              
                              String displayStatus = statusLayanan.isNotEmpty ? statusLayanan : status;
                              if (displayStatus.isEmpty) displayStatus = 'menunggu';
                              
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
                                          child: Text(
                                            nomorAntrian,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: kPrimary,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          nama,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(
                                              "Layanan: $jenisLayanan",
                                              style: GoogleFonts.poppins(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              "NIK: $nik",
                                              style: GoogleFonts.poppins(
                                                color: Colors.grey[700],
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              "Nomor Antrian: $nomorAntrian",
                                              style: GoogleFonts.poppins(
                                                color: Colors.grey[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: _buildStatusChip(displayStatus),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(user: {"id": widget.userId}),
              ),
            );
          } else if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
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
          Icon(Icons.queue_play_next_rounded,
              size: 90, color: Colors.white70),
          const SizedBox(height: 16),
          Text(
            "Belum Ada Antrian",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Data antrian Anda akan muncul di sini setelah pendaftaran diverifikasi.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              setState(() => isLoading = true);
              _fetchAntrianUser();
            },
            icon: const Icon(Icons.refresh),
            label: Text(
              "Refresh",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}