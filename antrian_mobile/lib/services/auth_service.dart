import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/login'), // Untuk Web
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "user": data["user"]};
      } else {
        return {"success": false, "message": data["message"] ?? "Login gagal"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
