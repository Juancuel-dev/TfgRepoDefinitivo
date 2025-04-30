import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_app/services/authProvider.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final bool showBackButton;

  // GlobalKey para controlar el estado del Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BaseLayout({super.key, required this.child, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; // Detectar si es móvil

    return Scaffold(
      key: _scaffoldKey, // Asignar el GlobalKey al Scaffold
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80), // Altura personalizada del AppBar
        child: AppBar(
          toolbarHeight: 80, // Ajustar la altura exacta del AppBar
          automaticallyImplyLeading: showBackButton,
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    context.go('/'); // Navegación al inicio
                  },
                  child: Container(
                    height: 60, // Altura máxima del logo
                    constraints: const BoxConstraints(
                      maxWidth: 200, // Ancho máximo para evitar que ocupe demasiado espacio
                    ),
                    child: Image.asset(
                      'logo.png', // Ruta al logo
                      fit: BoxFit.contain, // Ajustar la imagen sin recortarla
                    ),
                  ),
                ),
              ),
              const Spacer(), // Empujar los elementos hacia la derecha
            ],
          ),
          centerTitle: false, // Desactivar centrado del título
          actions: isMobile
              ? [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white), // Ícono de menú hamburguesa
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer(); // Abrir el Drawer
                      },
                    ),
                  ),
                ]
              : [
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
                          IconButton(
                            icon: const Icon(Icons.person, color: Colors.white), // Ícono de persona
                            onPressed: () {
                              context.go('/my-account'); // Navegación a My Account
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
        ),
      ),
      endDrawer: isMobile
          ? Drawer(
              backgroundColor: Colors.grey[900],
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                    ),
                    child: const Text(
                      'Menú',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.login, color: Colors.white),
                    title: const Text('Login', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      context.go('/login'); // Navegación al login
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.app_registration, color: Colors.white),
                    title: const Text('Registrarse', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      context.go('/register'); // Navegación al registro
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart, color: Colors.white),
                    title: const Text('Carrito', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      context.go('/cart'); // Navegación al carrito
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: const Text('Mi Cuenta', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      context.go('/my-account'); // Navegación a Mi Cuenta
                    },
                  ),
                ],
              ),
            )
          : null,
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