import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  List<dynamic> antrian = [];
  bool isLoading = false;

  final String baseUrl = "http://localhost:3000/api/antrian"; // Untuk browser

  @override
  void initState() {
    super.initState();
    fetchAntrian();
  }

  Future<void> fetchAntrian() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseUrl/daftar-antrian"));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          antrian = data["data"] ?? [];
          print('Antrian: $antrian');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateStatus(String id) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update-status/$id"),
        headers: {"Content-Type": "application/json"},
      );
      print('Update status response: ${response.statusCode}');
      print('Update status body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );
        await fetchAntrian(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memperbarui status: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> deleteAntrian(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/delete/$id"),
        headers: {"Content-Type": "application/json"},
      );
      print('Delete response: ${response.statusCode}');
      print('Delete body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );
        await fetchAntrian(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus antrian: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print('Error deleting antrian: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Antrian'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : antrian.isEmpty
              ? const Center(child: Text("Belum ada antrian"))
              : ListView.builder(
                  itemCount: antrian.length,
                  itemBuilder: (context, index) {
                    final item = antrian[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(item["nama"] ?? "Nama tidak tersedia"),
                        subtitle: Text(
                          "Nomor Antrian: ${item["nomor_antrian"]}\nStatus: ${item["status_layanan"]}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item["status_layanan"] != "Selesai")
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                onPressed: () => updateStatus(item["id"].toString()),
                              ),
                            if (item["status_layanan"] == "Selesai")
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteAntrian(item["id"].toString()),
                              ),
                          ],
                        ),
                        onTap: item["status_layanan"] != "Selesai"
                            ? () => updateStatus(item["id"].toString())
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}