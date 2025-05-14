import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/services/cart_provider.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';

class GameDetailPage extends StatelessWidget {
  final Game game;

  const GameDetailPage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagen del juego
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 300, // Máximo de 300px de altura
                  maxWidth: 600, // Máximo de 600px de ancho
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9, // Proporción 16:9 para una imagen amplia
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      game.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Nombre del juego
              Text(
                game.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Precio del juego
              Text(
                '${game.precio.toStringAsFixed(2)}€',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(height: 10),
              // Metacritic y consola
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDetailChip('Metacritic: ${game.metacritic}', Colors.orange),
                  const SizedBox(width: 10),
                  _buildDetailChip('Consola: ${game.consola}', Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                game.descripcion,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Botón para añadir al carrito
              ElevatedButton(
                onPressed: () {
                  // Usar el método addToCart del CartProvider
                  Provider.of<CartProvider>(context, listen: false).addToCart(game);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${game.name} añadido al carrito'),
                      duration: const Duration(seconds: 1), // Duración ajustada a 1 segundo
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Añadir al Carrito'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para mostrar detalles como chips
  Widget _buildDetailChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}