// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'daftarpendaftar_screen.dart';
import 'statuslayanan_screen.dart';
import 'antrian_screen.dart';
import 'admin_login_screen.dart';
import 'daftarantrian_screen.dart';
import '../providers/antrian_provider.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color kPrimary = Color(0xFF2563EB);
  static const Color kPrimaryDark = Color(0xFF1E3A8A);
  static const double kButtonWidth = 270;

  int _bottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            children: [
              // ======= HEADER + LOGO =======
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/logo.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        height: 74,
                        width: 74,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.apartment_rounded,
                            color: kPrimaryDark, size: 34),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "ANTRIAN ONLINE",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .4,
                      color: kPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "BADAN PENGELOLAAN KEUANGAN DAN ASET\nDAERAH KOTA PALOPO",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      height: 1.35,
                      color: Colors.blueGrey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ======= KARTU INFORMASI ANTRIAN (Realtime dari Provider) =======
              Consumer<AntrianProvider>(
                builder: (context, provider, _) {
                  final now = provider.nowServing;
                  final nowNumber =
                      now != null ? now['nomor_antrian']?.toString() ?? '—' : '—';
                  final total = provider.antrian.length;
                  final selesai = provider.antrian
                      .where((it) => it['status_layanan'] == 'Selesai')
                      .length;

                  return _InfoCard(
                    primary: kPrimary,
                    primaryDark: kPrimaryDark,
                    items: [
                      _InfoItem(label: "Nomor Saat Ini", value: nowNumber),
                      _InfoItem(label: "Total Antrian", value: "$total"),
                      _InfoItem(label: "Selesai Hari Ini", value: "$selesai"),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // ======= TOMBOL UTAMA =======
              _MainButton(
                title: "Daftar",
                icon: Icons.edit_note_rounded,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AntrianScreen()));
                },
                width: kButtonWidth,
              ),
              const SizedBox(height: 16),
              _MainButton(
                title: "Daftar Pendaftar",
                icon: Icons.people_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DaftarPendaftarScreen(userId: widget.user["id"]),
                    ),
                  );
                },
                width: kButtonWidth,
              ),
              const SizedBox(height: 16),
              _MainButton(
                title: "Daftar Antrian",
                icon: Icons.format_list_numbered_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DaftarAntrianScreen(userId: widget.user["id"]),
                    ),
                  );
                },
                width: kButtonWidth,
              ),
              const SizedBox(height: 16),
              _MainButton(
                title: "Status Layanan",
                icon: Icons.access_time_filled_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          StatusLayananScreen(userId: widget.user["id"]),
                    ),
                  );
                },
                width: kButtonWidth,
              ),

              const SizedBox(height: 28),

              // ======= INFORMASI TAMBAHAN =======
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Informasi Tambahan",
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      ListTile(
                        leading:
                            const Icon(Icons.access_time, color: kPrimaryDark),
                        title: const Text("Jam Operasional"),
                        subtitle:
                            const Text("Senin – Jumat, 08.00 – 16.00 WITA"),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on,
                            color: kPrimaryDark),
                        title: const Text("Alamat & Kontak"),
                        subtitle: const Text(
                            "Jl. Merdeka No. 45, Kota Palopo\nWhatsApp: 0821-xxxx-xxxx\nEmail: helpdesk@bpkad.go.id"),
                      ),
                      ListTile(
                        leading: const Icon(Icons.info_outline,
                            color: kPrimaryDark),
                        title: const Text("Tips"),
                        subtitle: const Text(
                            "Pastikan membawa dokumen lengkap sebelum menuju loket."),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ======= Bottom Nav =======
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (i) {
          if (i == 0) {
            setState(() => _bottomIndex = 0); // Home tetap
          } else if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminLoginScreen(),
              ),
            ).then((_) {
              setState(() => _bottomIndex = 0);
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimary,
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 11),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.login_rounded), label: "Login Admin"),
        ],
      ),
    );
  }
}

/// =====================
/// WIDGET KECIL REUSABLE
/// =====================

class _InfoCard extends StatelessWidget {
  final Color primary;
  final Color primaryDark;
  final List<_InfoItem> items;

  const _InfoCard({
    required this.primary,
    required this.primaryDark,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items
              .map((e) => Column(
                    children: [
                      Text(
                        e.value,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.label,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});
}

class _MainButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final double width;

  const _MainButton({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 3,
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: .3),
        ),
        onPressed: onTap,
      ),
    );
  }
}
