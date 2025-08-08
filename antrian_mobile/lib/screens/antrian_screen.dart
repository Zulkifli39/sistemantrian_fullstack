import 'package:flutter/material.dart';
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
  final TextEditingController layananController = TextEditingController();

  bool isLoading = false;
  String? nomorAntrian;

  Future<void> handleDaftar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      nomorAntrian = null;
    });

    final result = await AntrianService.daftarAntrian(
      nama: namaController.text,
      nik: nikController.text,
      jenisLayanan: layananController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (result["success"] != false) {
      setState(() {
        nomorAntrian = result["data"]?["nomor_antrian"]?.toString() ?? "-";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Pendaftaran berhasil"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Pendaftaran gagal"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Antrian"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nikController,
                decoration: const InputDecoration(
                  labelText: "NIK",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? "NIK wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: layananController,
                decoration: const InputDecoration(
                  labelText: "Jenis Layanan",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Jenis layanan wajib diisi"
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : handleDaftar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Daftar Sekarang",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              if (nomorAntrian != null) ...[
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Nomor Antrian Anda: $nomorAntrian",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
