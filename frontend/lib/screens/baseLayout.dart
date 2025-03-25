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
        backgroundColor: Colors.grey[900],
        actions: [],
      ),
      body: Column(
        children: [
          // Categories Bar
          Container(
            color: Colors.grey[900],
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Reducir el padding vertical
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0), // Agregar padding a la izquierda
                  child: Text(
                    'LevelUp Shop',
                    style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold), // Reducir el tamaño del texto
                  ),
                ),
                Spacer(),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCategoryChip('PC'),
                          _buildCategoryChip('XBOX'),
                          _buildCategoryChip('PS5'),
                          _buildCategoryChip('NINTENDO SWITCH'),
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Row(
                  children: [
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
                      icon: Icon(Icons.shopping_cart, color: Colors.white),
                      onPressed: () {
                        Navigator.pushNamed(context, '/cart');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          '© 2025 Tienda de Videojuegos',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: Colors.black, // Aseguramos que el fondo sea negro
    );
  }

  Widget _buildCategoryChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Chip(
        label: Text(label, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[800],
      ),
    );
  }
}