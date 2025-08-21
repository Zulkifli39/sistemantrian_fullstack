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
    setState(() {
      _selectedIndex = index;
    });
  }

  // 🔔 panggil next
  void _callNext(AntrianProvider provider) {
    provider.callNext();      // provider sudah bicara (TTS)
    _showSnackBar(provider);  // hanya SnackBar visual
  }

  // 🔔 panggil previous
  void _callPrevious(AntrianProvider provider) {
    provider.callPrevious();  // provider sudah bicara (TTS)
    _showSnackBar(provider);  // hanya SnackBar visual
  }

  // ✅ SnackBar visual (tanpa TTS)
  void _showSnackBar(AntrianProvider provider) {
    final item = provider.nowServing;
    if (item == null) return;

    final nomor = item['nomor_antrian']?.toString() ?? '—';
    final nama = item['nama'] ?? 'Pengguna';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Antrian Sekarang: $nomor — $nama',
          style: GoogleFonts.poppins(),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Admin Dashboard",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(),
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined), label: 'Verifikasi'),
          BottomNavigationBarItem(
              icon: Icon(Icons.update), label: 'Status'),
        ],
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
        final nowName =
            nowServing != null ? nowServing['nama'] ?? '-' : '-';

        final total = sorted.length;
        final selesai = sorted
            .where((it) => it['status_layanan'] == 'Selesai')
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selamat Datang, ${widget.admin['email'] ?? 'Admin'}",
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text("Berikut ringkasan aktivitas antrian hari ini.",
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 24),

                // Summary
                Row(children: [
                  _buildSummaryCard(
                      "Total Antrian", "$total", Icons.people, Colors.blue),
                  const SizedBox(width: 16),
                  _buildSummaryCard(
                      "Selesai", "$selesai", Icons.check_circle, Colors.green),
                ]),
                const SizedBox(height: 20),

                // Now Serving
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ]),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Now Serving",
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Row(children: [
                          // Nomor antrian aktif
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nowNumber,
                                      style: GoogleFonts.poppins(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700])),
                                  Text(nowName,
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[800])),
                                ]),
                          ),
                          const Spacer(),

                          // Prev/Next pakai provider
                          Column(children: [
                            ElevatedButton.icon(
                              onPressed: sorted.isEmpty ||
                                      provider.nowServingIndex <= 0
                                  ? null
                                  : () => _callPrevious(provider),
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  size: 16),
                              label:
                                  Text('Prev', style: GoogleFonts.poppins()),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: sorted.isEmpty ||
                                      provider.nowServingIndex >=
                                          sorted.length - 1
                                  ? null
                                  : () => _callNext(provider),
                              icon: const Icon(Icons.arrow_forward_ios,
                                  size: 16),
                              label:
                                  Text('Next', style: GoogleFonts.poppins()),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  foregroundColor: Colors.white),
                            ),
                          ])
                        ])
                      ]),
                ),
                const SizedBox(height: 20),

                // Daftar antrian
                Text("Daftar Antrian (Urut)",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ]),
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
                              const Divider(height: 1),
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
                                backgroundColor: isNow
                                    ? Colors.blue[700]
                                    : Colors.grey[200],
                                child: Text(nomor,
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: isNow
                                            ? Colors.white
                                            : Colors.black87)),
                              ),
                              title: Text(nama,
                                  style: GoogleFonts.poppins(
                                      fontWeight: isNow
                                          ? FontWeight.bold
                                          : FontWeight.w600)),
                              tileColor:
                                  isNow ? Colors.blue.withOpacity(0.04) : null,
                              onTap: () {
                                provider.setNowServing(index); // provider sudah bicara
                                _showSnackBar(provider);       // tampilkan SnackBar
                              },
                            );
                          },
                        ),
                ),
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
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(title, style: GoogleFonts.poppins(color: Colors.grey[700])),
          ]),
        ]),
      ),
    );
  }
}
