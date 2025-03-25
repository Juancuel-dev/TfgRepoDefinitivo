import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/models/cart.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';

class GameDetailPage extends StatelessWidget {
  final Game game;
  final Cart cart;

  GameDetailPage({required this.game, required this.cart});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      cart: cart,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 200, // Máximo de 200px de altura
                maxWidth: 200, // Máximo de 200px de ancho
              ),
              child: AspectRatio(
                aspectRatio: 1, // Proporción 1:1 para mantener la imagen cuadrada
                child: Image.network(
                  game.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text('Nombre: ${game.name}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Precio: \$${game.precio.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Metacritic: ${game.metacritic}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Consola: ${game.consola}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                cart.addItem(game);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${game.name} añadido al carrito')),
                );
              },
              child: const Text('Añadir al Carrito'),
            ),
          ],
        ),
      ),
    );
  }
}