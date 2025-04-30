import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String apiUrl = 'http://localhost:8080/gateway';

  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody['token']; // Assuming the JWT is returned in the 'token' field
    } else {
      return null;
    }
  }

  Future<bool> register(String nombre,String username, String password,String email) async {
    final response = await http.post(
      Uri.parse('$apiUrl/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': nombre,
        'password': password,
        'username': username,
        'email': email,
      }),
    );

    return response.statusCode == 201; // Assuming 201 Created is returned on successful registration
  }

  String? getRoleFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> payloadMap = jsonDecode(payload);

      return payloadMap['role'] as String?;
    } catch (e) {
      return null;
    }
  }
}