import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _loginUrl = "http://localhost:3000/api/auth/login"; // Berfungsi untuk web

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final resp = await http.post(
        Uri.parse(_loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      // Log bantu debug
      print("AUTH ${resp.statusCode} ${resp.headers['content-type']}");
      print("BODY: ${resp.body}");

      // Pastikan hanya parse bila benar2 JSON
      final ct = resp.headers['content-type'] ?? '';
      final looksJson = ct.contains('application/json') || resp.body.trim().startsWith('{');

      if (!looksJson) {
        return {
          "success": false,
          "message": "Server tidak mengembalikan JSON (mungkin salah method/URL). Status: ${resp.statusCode}",
        };
      }

      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data is Map && data['message'] == "Login admin berhasil") {
        return {
          "success": true,
          "user": data["admin"] ?? {}, // Pastikan 'admin' dipetakan ke 'user'
          "message": data["message"],
        };
      } else {
        return {
          "success": false,
          "message": (data is Map ? data["message"] : null) ?? "Login gagal",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }
}