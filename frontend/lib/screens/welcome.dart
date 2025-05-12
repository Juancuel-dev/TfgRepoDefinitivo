import 'package:flutter/material.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'package:go_router/go_router.dart'; // Importar GoRouter para la navegación

class WelcomePage extends StatelessWidget {
  final Function(String) onLogin;

  const WelcomePage({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      showBackButton: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.go('/login'); // Navegación con GoRouter a la pantalla de login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/register'); // Navegación con GoRouter a la pantalla de registro
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}