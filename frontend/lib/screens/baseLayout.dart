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
                      child: TextButton(
                        onPressed: () {
                          context.go('/'); // Navegación con GoRouter
                        },
                        child: Text(
                          'LevelUp Shop',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 24 : 40, // Ajustar tamaño del texto
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        final isLoggedIn = authProvider.isLoggedIn;

                        return Row(
                          children: [
                            if (isSmallScreen)
                              IconButton(
                                icon: const Icon(Icons.menu, color: Colors.white),
                                onPressed: () {
                                  _showMenu(context);
                                },
                              )
                            else ...[
                              if (!isLoggedIn) ...[
                                TextButton(
                                  onPressed: () {
                                    context.go('/login'); // Navegación con GoRouter
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.go('/register'); // Navegación con GoRouter
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
                                    context.go('/login'); // Navegación con GoRouter
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
                                  context.go('/cart'); // Navegación con GoRouter
                                },
                              ),
                            ],
                          ],
                        );
                      },
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
          '© 2025 LevelUp Shop. Todos los derechos reservados.',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  void _showMenu(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isLoggedIn;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.grey[900],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLoggedIn) ...[
                ListTile(
                  title: const Text('Login', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    context.go('/login'); // Navegación con GoRouter
                  },
                ),
                ListTile(
                  title: const Text('Registrarse', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    context.go('/register'); // Navegación con GoRouter
                  },
                ),
              ] else ...[
                ListTile(
                  title: const Text('Logout', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    authProvider.logout(); // Llamar al método de logout
                    context.go('/login'); // Navegación con GoRouter
                  },
                ),
              ],
              ListTile(
                title: const Text('Carrito', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.go('/cart'); // Navegación con GoRouter
                },
              ),
            ],
          ),
        );
      },
    );
  }
}