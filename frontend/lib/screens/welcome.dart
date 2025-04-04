import 'package:flutter/material.dart';
import 'package:flutter_auth_app/screens/login.dart';
import 'package:flutter_auth_app/screens/register.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';

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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(onLogin: onLogin)),
                );
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage(onRegister: onLogin)),
                );
              },
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}