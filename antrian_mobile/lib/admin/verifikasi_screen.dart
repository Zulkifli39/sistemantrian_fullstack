import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        Provider.of<AntrianProvider>(context, listen: false)
            .setPendaftar(data["data"]);
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
      final response =
          await http.post(Uri.parse("$baseUrl/verifikasi/$userId"));
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "✅ Diverifikasi! Nomor antrian: ${data['nomor_antrian']}")),
        );

        Provider.of<AntrianProvider>(context, listen: false)
            .updatePendaftarAfterVerification(
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
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            automaticallyImplyLeading: false, // Remove back button
            backgroundColor: Colors.blue[700],
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            title: Text(
              "Verifikasi Antrian",
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
              : antrianProvider.pendaftar.isEmpty
                  ? Center(
                      child: Text("Belum ada pendaftar",
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.grey[600])),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: antrianProvider.pendaftar.length,
                      itemBuilder: (context, index) {
                        final user = antrianProvider.pendaftar[index];
                        final nomorAntrian = user["nomor_antrian"];
                        final status = user["status_layanan"];
                        final userStatus = user["status"];

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
                              // Informasi User
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user["nama"],
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16)),
                                    const SizedBox(height: 6),
                                    Text("👤 NIK: ${user["nik"]}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey[700])),
                                    Text("📌 Layanan: ${user["jenis_layanan"]}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey[700])),
                                    Text(
                                        "📄 Status: ${userStatus ?? 'Menunggu Verifikasi'}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey[700])),
                                  ],
                                ),
                              ),

                              // Bagian kanan: tombol / nomor antrian
                              nomorAntrian == null &&
                                      userStatus != "Terverifikasi"
                                  ? ElevatedButton.icon(
                                      onPressed: () => verifikasiUser(
                                          user["user_id"], context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[600],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.check, size: 16),
                                      label: Text("Verifikasi",
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Chip(
                                          label: Text(
                                            "No: $nomorAntrian",
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[700]),
                                          ),
                                          backgroundColor: Colors.blue[50],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          status ?? "-",
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
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
