import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/screens/adminPanel.dart';
import 'package:flutter_auth_app/screens/categorypage.dart';
import 'package:flutter_auth_app/screens/main_screen.dart'; // Importar MainScreen
import 'package:flutter_auth_app/screens/searchpage.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_app/screens/login.dart';
import 'package:flutter_auth_app/screens/register.dart';
import 'package:flutter_auth_app/screens/cart.dart';
import 'package:flutter_auth_app/screens/details.dart';
import 'package:flutter_auth_app/services/cartProvider.dart';
import 'package:flutter_auth_app/services/authProvider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Configuración de rutas con GoRouter
    final GoRouter router = GoRouter(
      refreshListenable: authProvider, // Escucha cambios en AuthProvider
      initialLocation: '/', // Ruta inicial
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MainScreen(), // Página principal actualizada
        ),
        GoRoute(
          path: '/search/:query',
          builder: (context, state) {
            final query = state.pathParameters['query']!;
            return SearchPage(searchQuery: query);
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginPage(
            onLogin: (String newToken) {
              authProvider.setToken(newToken);
              context.go('/'); // Redirige a la raíz después del login
            },
          ),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => RegisterPage(
            onRegister: (String newToken) {
              authProvider.setToken(newToken);
              context.go('/'); // Redirige a la raíz después del registro
            },
          ),
        ),
        GoRoute(
          path: '/details',
          builder: (context, state) {
            // Verificar y convertir state.extra al tipo Game
            final game = state.extra is Game ? state.extra as Game : null;

            if (game == null) {
              // Manejar el caso en el que no se pase un objeto Game
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text('No se proporcionaron detalles del juego.'),
                ),
              );
            }

            return GameDetailPage(game: game);
          },
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminPanel(),
        ),
        GoRoute(
          path: '/category/:categoryName',
          builder: (context, state) {
            final categoryName = state.pathParameters['categoryName']; // Extraer el parámetro dinámico
            if (categoryName == null) {
              // Manejar el caso en el que no se pase un nombre de categoría
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text('No se proporcionó una categoría válida.'),
                ),
              );
            }
            return CategoryPage(category: categoryName); // Pasar la categoría a la página
          },
        ),
      ],
      redirect: (context, state) {
        final loggedIn = authProvider.isLoggedIn;

        // Permitir acceso público a las rutas no protegidas
        if (state.uri.path == '/' || state.uri.path.startsWith('/details')) {
          return null;
        }

        // Redirigir a /login si el usuario no está autenticado y está intentando acceder a rutas protegidas
        if (!loggedIn && (state.uri.path == '/cart' || state.uri.path == '/admin')) {
          return '/login';
        }

        // Redirigir a la raíz si el usuario ya está autenticado y está en /login
        if (loggedIn && state.uri.path == '/login') {
          return '/';
        }

        return null; // No redirige si no es necesario
      },
    );

    return MaterialApp.router(
      title: 'Tienda de Videojuegos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: router, // Configuración de GoRouter
      debugShowCheckedModeBanner: false, // Ocultar el banner de modo debug
    );
  }
}