// home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'daftarpendaftar_screen.dart';
import 'statuslayanan_screen.dart';
import 'antrian_screen.dart';
import 'admin_login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Warna utama modern
  static const Color kPrimary = Color(0xFF2563EB); // blue-600
  static const Color kPrimaryDark = Color(0xFF1E3A8A); // blue-900
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
                      height: 120, // Reduced from 120
                      width: 120,  // Reduced from 120
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
                  const SizedBox(height: 2), // Added small spacing
                  Text(
                    "ANTRIAN ONLINE",
                    style: GoogleFonts.poppins(
                      fontSize: 24, // Reduced from 26
                      fontWeight: FontWeight.w800,
                      letterSpacing: .4,
                      color: kPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced from 6
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

              // ======= KARTU INFORMASI ANTRIAN =======
              _InfoCard(
                primary: kPrimary,
                primaryDark: kPrimaryDark,
                items: const [
                  _InfoItem(label: "Nomor Saat Ini", value: "A-05"),
                  _InfoItem(label: "Total Antrian", value: "24"),
                  _InfoItem(label: "Selesai Hari Ini", value: "18"),
                ],
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
                        leading: const Icon(Icons.access_time,
                            color: kPrimaryDark),
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
                        leading:
                            const Icon(Icons.info_outline, color: kPrimaryDark),
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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (i) {
          if (i == 0) {
            setState(() => _bottomIndex = 0); // Home tetap
          } else if (i == 1) {
            // Navigate to the actual AdminLoginScreen
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => const AdminLoginScreen()
              )
            ).then((_) {
              // Reset bottom index when returning
              setState(() => _bottomIndex = 0);
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimary,
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500, fontSize: 11),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_rounded), label: "Login Admin"),
        ],
      ),
    );
  }
}

// ====================== WIDGET KARTU INFO ======================
class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;
  final Color primary;
  final Color primaryDark;
  const _InfoCard({
    required this.items,
    required this.primary,
    required this.primaryDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Informasi Antrian",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Expanded(child: _InfoTile(item: items[i])),
                if (i != items.length - 1)
                  Container(
                    width: 1,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: Colors.white.withOpacity(.35),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});
}

class _InfoTile extends StatelessWidget {
  final _InfoItem item;
  const _InfoTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          item.label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
      ],
    );
  }
}

// ====================== WIDGET TOMBOL ======================
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
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 22),
        label: Text(
          title,
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16.5,
              fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E6BFF),
          elevation: 8,
          shadowColor: const Color(0xFF2E6BFF).withOpacity(.45),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
      ),
    );
  }
}
