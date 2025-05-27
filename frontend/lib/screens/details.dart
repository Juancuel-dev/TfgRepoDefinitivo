import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/services/cart_provider.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_auth_app/config/server_config.dart';

class GameDetailPage extends StatefulWidget {
  final String gameName;

  const GameDetailPage({super.key, required this.gameName});

  @override
  _GameDetailPageState createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  late Future<Game> _gameFuture;

  @override
  void initState() {
    super.initState();
    _gameFuture = _fetchGameDetailsByName(widget.gameName);
  }

  Future<Game> _fetchGameDetailsByName(String gameName) async {
    final response = await http.get(Uri.parse('${ServerConfig.serverIp}/gateway/games/name/$gameName'));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return Game.fromJson(data);
    } else {
      throw Exception('Failed to load game details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: FutureBuilder<Game>(
        future: _gameFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No se encontraron detalles del juego.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final game = snapshot.data!;
          return _buildGameDetails(context, game);
        },
      ),
    );
  }

  Widget _buildGameDetails(BuildContext context, Game game) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Imagen de fondo
        Positioned.fill(
          child: Image.network(
            game.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        // Gradiente superpuesto para reducir la prominencia de la imagen de fondo
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.9), // Más oscuro en la parte inferior
                  Colors.black.withOpacity(0.7), // Menos oscuro en la parte superior
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        // Detalles del juego
        SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800), // Limitar el ancho máximo
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.05), // Espaciado superior
                    // Imagen del juego en primer plano
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.network(
                        game.imageUrl,
                        fit: BoxFit.cover,
                        width: screenWidth * 0.8, // Imagen responsive
                        height: screenHeight * 0.3,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Nombre del juego
                    Text(
                      game.name,
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? screenWidth * 0.07 : 32, // Tamaño adaptativo
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Precio del juego
                    Text(
                      '${game.precio.toStringAsFixed(2)}€',
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? screenWidth * 0.06 : 28, // Tamaño adaptativo
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Metacritic y consola
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDetailChip('Metacritic: ${game.metacritic}', Colors.orange),
                        const SizedBox(width: 10),
                        _buildDetailChip('Plataforma: ${game.consola}', Colors.blueAccent),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Descripción del juego
                    Text(
                      game.descripcion,
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? screenWidth * 0.045 : 16, // Tamaño adaptativo
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Botón para añadir al carrito
                    GestureDetector(
                      onTap: () {
                        // Usar el método addToCart del CartProvider
                        Provider.of<CartProvider>(context, listen: false).addToCart(game);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${game.name} añadido al carrito'),
                            duration: const Duration(seconds: 1), // Duración ajustada a 1 segundo
                          ),
                        );
                      },
                      child: Container(
                        width: screenWidth < 600 ? screenWidth * 0.6 : 300, // Botón responsive
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'Añadir al Carrito',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth < 600 ? screenWidth * 0.05 : 18, // Tamaño adaptativo
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05), // Espaciado inferior
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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