import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/screens/login.dart';
import 'package:flutter_auth_app/screens/home.dart';
import 'package:flutter_auth_app/screens/details.dart';
import 'package:flutter_auth_app/screens/register.dart';
import 'package:flutter_auth_app/screens/welcome.dart';
import 'package:flutter_auth_app/screens/cart.dart';
import 'package:flutter_auth_app/models/cart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Cart cart = Cart();
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
        '/': (context) => WelcomePage(cart: cart, onLogin: (String newToken) {
          setState(() {
            token = newToken;
          });
          Navigator.pushReplacementNamed(context, '/home');
        }),
        '/login': (context) => LoginPage(cart: cart, onLogin: (String newToken) {
          setState(() {
            token = newToken;
          });
          Navigator.pushReplacementNamed(context, '/home');
        }),
        '/home': (context) => HomePage(cart: cart, token: token!),
        '/details': (context) => GameDetailPage(cart: cart, game: ModalRoute.of(context)!.settings.arguments as Game),
        '/register': (context) => RegisterPage(cart: cart, onRegister: (String newToken) {
          setState(() {
            token = newToken;
          });
          Navigator.pushReplacementNamed(context, '/home');
        }),
        '/cart': (context) => CartPage(cart: cart, token: token!),
      },
    );
  }
}