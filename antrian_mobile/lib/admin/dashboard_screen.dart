import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'verifikasi_screen.dart';
import 'status_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> admin;

  const DashboardScreen({super.key, required this.admin});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Daftar halaman untuk Bottom Navigation
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildDashboardHome(context), // Halaman utama dengan chart
      const VerifikasiScreen(),      // Halaman verifikasi
      const StatusScreen(),          // Halaman status
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
            onPressed: () {
              // Logika logout
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined),
            label: 'Verifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'Status',
          ),
        ],
      ),
    );
  }

  // WIDGET UNTUK HALAMAN UTAMA DASHBOARD (DENGAN CHART)
  Widget _buildDashboardHome(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Text(
            "Selamat Datang, ${widget.admin['email'] ?? 'Admin'}",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Berikut ringkasan aktivitas antrian hari ini.",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Kartu Ringkasan
          Row(
            children: [
              _buildSummaryCard("Total Antrian", "150", Icons.people, Colors.blue),
              const SizedBox(width: 16),
              _buildSummaryCard("Selesai", "120", Icons.check_circle, Colors.green),
            ],
          ),
          const SizedBox(height: 24),

          // Judul Chart
          Text(
            "Statistik Antrian Mingguan",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Widget Chart
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: BarChart(
              _buildWeeklyBarChartData(), // Data untuk chart
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk kartu ringkasan
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  // DATA DUMMY UNTUK BAR CHART
  BarChartData _buildWeeklyBarChartData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 20, // Nilai Y maksimal
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
              String text;
              switch (value.toInt()) {
                case 0: text = 'Sn'; break;
                case 1: text = 'Sl'; break;
                case 2: text = 'Rb'; break;
                case 3: text = 'Km'; break;
                case 4: text = 'Jm'; break;
                case 5: text = 'Sb'; break;
                case 6: text = 'Mg'; break;
                default: text = ''; break;
              }
              return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
            },
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: [
        _makeBarChartGroupData(0, 5),
        _makeBarChartGroupData(1, 12),
        _makeBarChartGroupData(2, 8),
        _makeBarChartGroupData(3, 15),
        _makeBarChartGroupData(4, 7),
        _makeBarChartGroupData(5, 10),
        _makeBarChartGroupData(6, 3),
      ],
    );
  }

  BarChartGroupData _makeBarChartGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue[400],
          width: 22,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}
