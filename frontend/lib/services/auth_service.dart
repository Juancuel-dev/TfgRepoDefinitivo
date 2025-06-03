import 'dart:convert';
import 'package:flutter_auth_app/config/server_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiUrl = '${ServerConfig.serverIp}/gateway';

  Future<String> login(String username, String password) async {
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
      return "";
    }
  }

  Future<bool> register(String nombre, String username, String password, String email, int edad, String pais) async {
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
        'edad': edad,
        'pais': pais, 
      }),
    );
    print(pais);
    print(edad);
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

  String? getClaimFromToken(String token, String claim) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Invalid token');
    
    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    
    return payloadMap[claim]?.toString(); // Convierte a String por seguridad
  } catch (e) {
    print('Error decoding token: $e');
    return null;
  }
}

String _decodeBase64(String str) {
  String output = str.replaceAll('-', '+').replaceAll('_', '/');
  
  switch (output.length % 4) {
    case 0: break;
    case 2: output += '=='; break;
    case 3: output += '='; break;
    default: throw Exception('Illegal base64url string!');
  }
  
  return utf8.decode(base64Url.decode(output));
}

Future<Map<String, dynamic>?> fetchUserInfo(String jwtToken) async {
    const url = '${ServerConfig.serverIp}/gateway/users/me'; 

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $jwtToken', // Agregar el token JWT en el encabezado
        },
      );

      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Error al obtener la información del usuario: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      return null;
    }
  }
  // Guarda token en SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Obtiene token guardado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}