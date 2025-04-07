import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _jwtToken;

  String? get jwtToken => _jwtToken;

  /// Verifica si el usuario está autenticado
  bool get isLoggedIn => _jwtToken != null;

  /// Establece el token JWT
  void setToken(String token) {
    _jwtToken = token;
    notifyListeners();
  }

  /// Limpia el token JWT (logout)
  void clearToken() {
    _jwtToken = null;
    notifyListeners();
  }

  /// Realiza el logout del usuario
  void logout() {
    clearToken(); // Llama a clearToken para limpiar el estado de autenticación
    // Aquí puedes agregar lógica adicional si es necesario
  }
}