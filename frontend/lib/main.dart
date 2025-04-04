import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/screens/login.dart';
import 'package:flutter_auth_app/screens/home.dart';
import 'package:flutter_auth_app/screens/details.dart';
import 'package:flutter_auth_app/screens/register.dart';
import 'package:flutter_auth_app/screens/cart.dart';
import 'package:flutter_auth_app/services/cartProvider.dart';
import 'package:flutter_auth_app/services/authService.dart';
import 'package:flutter_auth_app/services/authProvider.dart'; // Importa el AuthProvider

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()), // Proveedor global para el carrito
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Proveedor global para el token JWT
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  String? token;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda de Videojuegos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(token: token ?? ''),
        '/login': (context) => LoginPage(onLogin: (String newToken) {
          setState(() {
            token = newToken;
            Provider.of<AuthProvider>(context, listen: false).setToken(newToken); // Establece el token en el AuthProvider
          });
          Navigator.pushReplacementNamed(context, '/home', arguments: token);
        }),
        '/home': (context) => HomePage(token: token ?? ''),
        '/details': (context) => GameDetailPage(
              game: ModalRoute.of(context)!.settings.arguments as Game,
            ),
        '/register': (context) => RegisterPage(onRegister: (String newToken) {
          setState(() {
            token = newToken;
            Provider.of<AuthProvider>(context, listen: false).setToken(newToken); // Establece el token en el AuthProvider
          });
          Navigator.pushReplacementNamed(context, '/home', arguments: token);
        }),
        '/cart': (context) => const CartPage(), // El carrito y el token se obtienen desde los Providers
      },
    );
  }
}