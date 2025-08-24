import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'verifikasi_screen.dart';
import 'status_screen.dart';
import '../providers/antrian_provider.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> admin;

  const DashboardScreen({super.key, required this.admin});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildDashboardHome(),
      const VerifikasiScreen(),
      const StatusScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _callNext(AntrianProvider provider) {
    provider.callNext();
    _showSnackBar(provider);
  }

  void _callPrevious(AntrianProvider provider) {
    provider.callPrevious();
    _showSnackBar(provider);
  }

  void _callRepeat(AntrianProvider provider) {
    provider.panggilUlang();
    _showSnackBar(provider);
  }

  void _showSnackBar(AntrianProvider provider) {
    final item = provider.nowServing;
    if (item == null) return;

    final nomor = item['nomor_antrian']?.toString() ?? '—';
    final nama = item['nama'] ?? 'Pengguna';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Antrian Sekarang: $nomor — $nama',
            style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // Modern AppBar
      appBar: _selectedIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false, // Add this to remove back arrow
              elevation: 4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              backgroundColor: Colors.blue[700],
              title: Text(
                "Admin Dashboard",
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
            )
          : null,

      body: IndexedStack(index: _selectedIndex, children: _pages),

      // Floating Bottom Nav
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue[700],
            unselectedItemColor: Colors.grey[500],
            selectedLabelStyle:
                GoogleFonts.poppins(fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.poppins(),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.verified_user_outlined), label: 'Verifikasi'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.update), label: 'Status'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardHome() {
    return Consumer<AntrianProvider>(
      builder: (context, provider, child) {
        final sorted = provider.antrian;
        final nowServing = provider.nowServing;
        final nowNumber =
            nowServing != null ? nowServing['nomor_antrian']?.toString() ?? '—' : '—';
        final nowName = nowServing != null ? nowServing['nama'] ?? '-' : '-';

        final total = sorted.length;
        final selesai = sorted
            .where((it) => it['status_layanan'] == 'Selesai')
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Selamat Datang, ${widget.admin['email'] ?? 'Admin'}",
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 6),
                Text("Berikut ringkasan aktivitas antrian hari ini.",
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 20),

                // Summary Cards
                Row(children: [
                  _buildSummaryCard(
                      "Total Antrian", "$total", Icons.people, Colors.blue),
                  const SizedBox(width: 16),
                  _buildSummaryCard(
                      "Selesai", "$selesai", Icons.check_circle, Colors.green),
                ]),
                const SizedBox(height: 20),

                // Now Serving Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.blue[600]!, Colors.blue[800]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Sedang Dilayani",
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 10),
                      Row(children: [
                        Text(nowNumber,
                            style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(width: 12),
                        Text(nowName,
                            style: GoogleFonts.poppins(
                                fontSize: 18, color: Colors.white)),
                        const Spacer(),
                        Icon(Icons.volume_up, color: Colors.white, size: 28)
                      ]),
                      const SizedBox(height: 14),

                      // Buttons
                      Row(children: [
                        _actionButton("Prev", Icons.arrow_back_ios_new,
                            Colors.white, Colors.blue[900]!, () {
                          if (provider.nowServingIndex > 0) {
                            _callPrevious(provider);
                          }
                        }),
                        const SizedBox(width: 8),
                        _actionButton("Ulang", Icons.replay, Colors.orange,
                            Colors.white, () => _callRepeat(provider)),
                        const SizedBox(width: 8),
                        _actionButton("Next", Icons.arrow_forward_ios,
                            Colors.white, Colors.green, () {
                          if (provider.nowServingIndex < sorted.length - 1) {
                            _callNext(provider);
                          }
                        }),
                      ])
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Daftar Antrian
                Text("Daftar Antrian",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: sorted.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                              child: Text("Tidak ada antrian",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey[600]))),
                        )
                      : ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: sorted.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final item = sorted[index];
                            final nomor =
                                item['nomor_antrian']?.toString() ?? '-';
                            final nama = item['nama'] ?? '-';
                            final isNow =
                                index == provider.nowServingIndex;
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor:
                                    isNow ? Colors.blue[700] : Colors.grey[300],
                                child: Text(nomor,
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isNow
                                            ? Colors.white
                                            : Colors.black)),
                              ),
                              title: Text(nama,
                                  style: GoogleFonts.poppins(
                                      fontWeight: isNow
                                          ? FontWeight.bold
                                          : FontWeight.w500)),
                              tileColor:
                                  isNow ? Colors.blue.withOpacity(0.08) : null,
                              onTap: () {
                                provider.setNowServing(index);
                                _showSnackBar(provider);
                              },
                            );
                          },
                        ),
                )
              ]),
        );
      },
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 12),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text(title,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70))
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text, IconData icon, Color bg, Color fg,
      VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: fg),
        label: Text(text,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: fg)),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
        ),
      ),
    );
  }
}
