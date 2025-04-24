import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_app/services/authProvider.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final bool showBackButton;

  const BaseLayout({super.key, required this.child, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80), // Altura personalizada del AppBar
        child: AppBar(
          automaticallyImplyLeading: showBackButton,
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.go('/'); // Navegación al inicio
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0), // Espacio solo en la parte superior
                  child: Image.asset(
                    'logo.png', // Ruta al logo
                    height: 60, // Tamaño del logo acorde al header
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Spacer(), // Empujar los elementos hacia la derecha
            ],
          ),
          centerTitle: false, // Desactivar centrado del título
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                _showSearchDialog(context); // Mostrar el cuadro de búsqueda
              },
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final isLoggedIn = authProvider.isLoggedIn;

                return Row(
                  children: [
                    if (!isLoggedIn) ...[
                      TextButton(
                        onPressed: () {
                          context.go('/login'); // Navegación al login
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/register'); // Navegación al registro
                        },
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ] else ...[
                      TextButton(
                        onPressed: () {
                          authProvider.logout(); // Llamar al método de logout
                          context.go('/login'); // Navegación al login
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      onPressed: () {
                        context.go('/cart'); // Navegación al carrito
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          '© 2025 LevelUp Shop. Todos los derechos reservados.',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Buscar Juegos',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Introduce el nombre del juego',
              hintStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                final searchQuery = searchController.text.trim();
                if (searchQuery.isNotEmpty) {
                  Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                  context.go('/search/$searchQuery'); // Navegar a la página de búsqueda
                }
              },
              child: const Text('Buscar', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}