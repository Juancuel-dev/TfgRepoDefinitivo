import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/cart.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final Cart cart;

  const BaseLayout({super.key, required this.child, required this.cart, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        backgroundColor: Colors.grey[900],
        actions: const [],
      ),
      body: Column(
        children: [
          // Responsive Header
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;

                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'LevelUp Shop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 24 : 40, // Ajustar tamaño del texto
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    
                    const Spacer(),
                    Row(
                      children: [
                        if (isSmallScreen)
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {
                              _showMenu(context);
                            },
                          )
                        else ...[
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
                            icon: const Icon(Icons.shopping_cart, color: Colors.white),
                            onPressed: () {
                              Navigator.pushNamed(context, '/cart');
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              },
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
      backgroundColor: Colors.black,
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.grey[900],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Login', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              ListTile(
                title: const Text('Registrarse', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
              ),
              ListTile(
                title: const Text('Carrito', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}