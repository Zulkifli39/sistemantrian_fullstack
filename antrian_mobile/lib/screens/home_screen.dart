import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'daftarpendaftar_screen.dart';
import 'daftarantrian_screen.dart';
import 'statuslayanan_screen.dart';
import 'admin_login_screen.dart';
import 'antrian_screen.dart';
// Import halaman login Anda, ganti 'login_screen.dart' dengan nama file yang benar
// import 'login_screen.dart'; 

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan di body
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      _buildHomeDashboard(context), // Halaman Utama (Dashboard)
      DaftarPendaftarScreen(userId: widget.user["id"]), // Halaman Daftar Pendaftar
      const AntrianScreen(), // Halaman Ambil Antrian
      StatusLayananScreen(userId: widget.user["id"]), // Halaman Status Layanan
      _buildProfilePage(context), // Halaman Profil & Admin
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berubah sesuai item yang dipilih di bottom navigation
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Utama',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Pendaftar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_card_outlined),
            label: 'Ambil Antrian',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_toggle_off_rounded), // Ikon diubah agar tidak sama
            label: 'Status Layanan', // Label disesuaikan dengan nama screen
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Style untuk bottom navigation bar yang modern
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(),
        elevation: 10,
      ),
    );
  }

  // WIDGET UNTUK HALAMAN UTAMA (TAB 1)
  Widget _buildHomeDashboard(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang,',
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16),
            ),
            Text(
              // PERBAIKAN: Menambahkan fallback jika 'nama' null untuk mencegah error
              widget.user['nama'] ?? 'Pengguna',
              style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, color: Colors.blue[800]),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Informasi Antrian Utama
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Antrian Saat Ini',
                    style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8), fontSize: 16),
                  ),
                  Text(
                    'A-05', // TODO: Ganti dengan data asli dari API
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nomor Anda',
                            style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8)),
                          ),
                          Text(
                            'A-12', // TODO: Ganti dengan data asli dari API
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimasi Waktu',
                            style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8)),
                          ),
                          Text(
                            '15 Menit', // TODO: Ganti dengan data asli dari API
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Judul Layanan
            Text(
              'Layanan Tersedia',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Daftar Layanan
            _buildServiceTile(Icons.support_agent, 'Layanan Pelanggan',
                'Bantuan dan informasi umum.'),
            _buildServiceTile(Icons.how_to_reg, 'Pendaftaran Baru',
                'Pendaftaran untuk layanan baru.'),
            _buildServiceTile(
                Icons.payment, 'Pembayaran', 'Layanan kasir dan pembayaran.'),
          ],
        ),
      ),
    );
  }

  // WIDGET UNTUK HALAMAN PROFIL (TAB 4)
  Widget _buildProfilePage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil & Pengaturan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Tombol Login Admin
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminLoginScreen()),
                );
              },
              leading: Icon(Icons.admin_panel_settings, color: Colors.red[700]),
              title: Text('Login Sebagai Admin',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 16),
            // Tombol Logout
            ListTile(
              onTap: () {
                // PERBAIKAN: Logika logout ditambahkan
                // Kembali ke halaman login dan hapus semua halaman sebelumnya
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AdminLoginScreen()), // Ganti dengan halaman login user Anda
                  (Route<dynamic> route) => false,
                );
              },
              leading: Icon(Icons.logout, color: Colors.grey[700]),
              title: Text('Logout',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk item layanan
  Widget _buildServiceTile(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[700], size: 30),
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins()),
      ),
    );
  }
}
