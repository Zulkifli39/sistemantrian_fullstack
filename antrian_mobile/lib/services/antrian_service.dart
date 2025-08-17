import 'dart:convert';
import 'package:http/http.dart' as http;

class AntrianService {
  static const String baseUrl = "http://localhost:3000/api/users";

  // Daftar user baru untuk antrian
  static Future<Map<String, dynamic>> daftarAntrian({
    required String nama,
    required String nik,
    required String jenisLayanan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/daftar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama": nama,
          "nik": nik,
          "jenis_layanan": jenisLayanan,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)["message"] ??
              "Gagal mendaftar"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
