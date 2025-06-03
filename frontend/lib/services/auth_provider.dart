import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _jwtToken;
  bool _sessionActive = false;

  String? get jwtToken => _sessionActive ? _jwtToken : null;
  bool get isLoggedIn => _sessionActive && _jwtToken != null;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    await _loadAndValidateToken();
  }

  Future<void> _loadAndValidateToken() async {
    final prefs = await SharedPreferences.getInstance();
    _jwtToken = prefs.getString('auth_token');
    _sessionActive = prefs.getBool('session_active') ?? false;
    
    // Validar el token si existe
    if (_jwtToken != null) {
      final isValid = await _validateToken(_jwtToken!);
      if (!isValid) {
        await _clearSession();
      } else {
        _sessionActive = true;
        await prefs.setBool('session_active', true);
      }
    }
    
    notifyListeners();
  }

  Future<bool> _validateToken(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      final payload = _decodeBase64(parts[1]);
      final claims = json.decode(payload) as Map<String, dynamic>;
      
      // Verificar expiración
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

  Future<void> setToken(String token) async {
    if (await _validateToken(token)) {
      _jwtToken = token;
      _sessionActive = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setBool('session_active', true);
      notifyListeners();
    } else {
      await _clearSession();
      throw Exception('Invalid token');
    }
  }

  Future<void> _clearSession() async {
    _jwtToken = null;
    _sessionActive = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.setBool('session_active', false);
    notifyListeners();
  }

  Future<void> logout() async {
    await _clearSession();
    // Aquí puedes agregar lógica adicional de limpieza
  }

  // Método para forzar cierre de sesión cuando se detecta un token inválido
  Future<void> forceLogout() async {
    await _clearSession();
    debugPrint('Forced logout due to invalid session');
  }
}