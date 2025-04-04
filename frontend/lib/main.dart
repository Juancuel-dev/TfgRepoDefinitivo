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

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()), // Proveedor global para el carrito
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
          });
          Navigator.pushReplacementNamed(context, '/home', arguments: token);
        }),
        '/cart': (context) => const CartPage(token: ""), // El carrito se obtiene desde el Provider
      },
    );
  }
}