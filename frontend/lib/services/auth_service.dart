import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_auth_app/config/server_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiUrl = '${ServerConfig.serverIp}/gateway';
  final String _tokenKey = 'auth_token';
  final String _sessionActiveKey = 'session_active';
  
  // Stream para controlar el estado de autenticación
  final StreamController<bool> _authStreamController = StreamController<bool>.broadcast();
  Stream<bool> get authStatusStream => _authStreamController.stream;

  Future<String> login(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final token = responseBody['token'] as String;

      if (_isTokenValid(token)) {
        await _saveSession(token);
        _authStreamController.add(true);
        return token;
      } else {
        throw Exception('Invalid token received');
      }
    } else if (response.statusCode == 403) {
      throw Exception('403');  // Lanzamos excepción específica para 403
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  } catch (e) {
    _authStreamController.add(false);
    rethrow;
  }
}


  Future<bool> register(String nombre, String username, String password, 
                       String email, int edad, String pais) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'password': password,
          'username': username,
          'email': email,
          'edad': edad,
          'pais': pais,
        }),
      ).timeout(const Duration(seconds: 30));

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  Future<void> _saveSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_sessionActiveKey, true);
    
    if (kIsWeb) {
      // Configuración adicional para web si es necesario
      _setupWebSessionCleanup();
    }
  }

  void _setupWebSessionCleanup() {
    // Intenta limpiar la sesión al cerrar la pestaña (solo web)
    // Nota: Esto no es 100% confiable en todos los navegadores
    try {
      /* 
      // Implementación real requeriría dart:html o universal_html
      import 'dart:html' as html;
      html.window.addEventListener('beforeunload', (event) async {
        await logout();
      });
      */
    } catch (e) {
      debugPrint('Error setting up web cleanup: $e');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final isSessionActive = prefs.getBool(_sessionActiveKey) ?? false;
    if (!isSessionActive) return null;
    
    final token = prefs.getString(_tokenKey);
    if (token != null && _isTokenValid(token)) {
      return token;
    }
    return null;
  }

  bool _isTokenValid(String token) {
  try {
    // Decodificar el token sincrónicamente ya que ya lo tenemos
    final parts = token.split('.');
    if (parts.length != 3) return false;
    
    final payload = _decodeBase64(parts[1]);
    final claims = json.decode(payload) as Map<String, dynamic>;
    
    // Verificar expiración (si el token incluye 'exp')
    final expiry = claims['exp'] as int?;
    if (expiry != null) {
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
      return expiryDate.isAfter(DateTime.now());
    }
    
    return true;
  } catch (e) {
    debugPrint('Error validating token: $e');
    return false;
  }
}

  Future<Map<String, dynamic>?> getClaimsFromToken(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = _decodeBase64(parts[1]);
      return json.decode(payload) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding token: $e');
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.setBool(_sessionActiveKey, false);
    _authStreamController.add(false);
  }

  Future<Map<String, dynamic>?> fetchUserInfo() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$apiUrl/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // Si el token es inválido, limpiamos la sesión
        if (response.statusCode == 401) {
          await logout();
        }
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
      return null;
    }
  }
  // Método para decodificar el payload del token
Map<String, dynamic>? _decodeTokenPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    
    final payload = _decodeBase64(parts[1]);
    return json.decode(payload) as Map<String, dynamic>;
  } catch (e) {
    debugPrint('Error decoding token payload: $e');
    return null;
  }
}

// Método para obtener claims del token (versión síncrona)
String? getClaimFromToken(String token, String claim) {
  final claims = _decodeTokenPayload(token);
  return claims?[claim]?.toString();
}

// Método para obtener el rol del token (versión síncrona)
String? getRoleFromToken(String token) {
  return getClaimFromToken(token, 'role');
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

  // Verificación de sesión activa
  Future<bool> checkActiveSession() async {
    final token = await getToken();
    return token != null;
  }

  // Limpieza para cuando se detecte un estado inconsistente
  Future<void> clearInvalidSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    
    if (token != null && !_isTokenValid(token)) {
      await logout();
    }
  }

  // Cerrar el stream controller cuando ya no se necesite
  void dispose() {
    _authStreamController.close();
  }
}