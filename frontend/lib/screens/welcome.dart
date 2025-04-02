import 'package:flutter/material.dart';
import 'package:flutter_auth_app/screens/login.dart';
import 'package:flutter_auth_app/screens/register.dart';
import 'package:flutter_auth_app/models/cart.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';

class WelcomePage extends StatelessWidget {
  final Cart cart;
  final Function(String) onLogin;

  const WelcomePage({super.key, required this.cart, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      cart: cart,
      showBackButton: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(cart: cart, onLogin: onLogin)),
                );
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage(cart: cart, onRegister: onLogin)),
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