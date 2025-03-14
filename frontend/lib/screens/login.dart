import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/cart.dart';

class LoginPage extends StatelessWidget {
  final Cart cart;
  final Function(String) onLogin;

  LoginPage({required this.cart, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Simular login y obtener token
            String token = 'your-jwt-token';
            onLogin(token);
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}