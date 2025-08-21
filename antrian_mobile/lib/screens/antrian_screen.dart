import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/antrian_service.dart';

class AntrianScreen extends StatefulWidget {
  const AntrianScreen({super.key});

  @override
  State<AntrianScreen> createState() => _AntrianScreenState();
}

class _AntrianScreenState extends State<AntrianScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  String? _selectedLayanan;

  final List<String> _layananOptions = [
    'Desposisi surat masuk',
    'Register spm ls',
    'pengurusan skpp gaji',
    'Spm ls listrik',
    'Spm ls honor',
    'Spm pekerjaan',
  ];

  bool isLoading = false;

  Future<void> handleDaftar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    final result = await AntrianService.daftarAntrian(
      nama: namaController.text,
      nik: nikController.text,
      jenisLayanan: _selectedLayanan!,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Pendaftaran berhasil!"),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
      _formKey.currentState?.reset();
      namaController.clear();
      nikController.clear();
      setState(() {
        _selectedLayanan = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Pendaftaran gagal, coba lagi."),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Ambil Nomor Antrian", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: AnimationLimiter(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                // Header Image
                Image.asset(
                  'assets/queue_illustration.png', // **Pastikan Anda memiliki gambar ini di folder assets**
                  height: 180,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.people_alt_rounded, size: 150, color: Colors.blue[200]),
                ),
                const SizedBox(height: 20),
                Text(
                  "Daftar Untuk Antrian",
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Isi data diri Anda untuk mendapatkan nomor antrian layanan.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextFormField(
                        controller: namaController,
                        labelText: "Nama Lengkap",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: nikController,
                        labelText: "Nomor Induk Kependudukan (NIK)",
                        icon: Icons.credit_card_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      // PERUBAHAN: Mengganti TextFormField dengan Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedLayanan,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Jenis Layanan yang Dituju",
                          labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
                          prefixIcon: Icon(Icons.business_center_outlined, color: Colors.blue[700]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                        ),
                        hint: Text("Pilih Layanan", style: GoogleFonts.poppins()),
                        items: _layananOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: GoogleFonts.poppins()),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLayanan = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Jenis layanan wajib dipilih' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleDaftar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      shadowColor: Colors.blue.withOpacity(0.4),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : Text(
                            "Daftar Sekarang",
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? "$labelText wajib diisi" : null,
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    nikController.dispose();
    super.dispose();
  }
}

