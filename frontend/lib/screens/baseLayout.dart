import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/cart.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final Cart cart;

  BaseLayout({required this.child, required this.cart, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        title: const Text('Tienda de Videojuegos'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/register');
            },
            child: const Text(
              'Registrarse',
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: child),
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Footer de la Tienda de Videojuegos',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}