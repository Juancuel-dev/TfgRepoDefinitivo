import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/services/gamesService.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BaseLayout(
      showBackButton: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alinear contenido a la izquierda
            children: [
              // Categorías principales (centradas y justo debajo del header)
              Center(
                child: Wrap(
                  spacing: 8.0, // Espaciado horizontal entre los botones
                  runSpacing: 8.0, // Espaciado vertical entre filas
                  alignment: WrapAlignment.center,
                  children: [
                    _buildResponsiveCategoryChip(context, 'PC', screenWidth),
                    _buildResponsiveCategoryChip(context, 'XBOX', screenWidth),
                    _buildResponsiveCategoryChip(context, 'PS5', screenWidth),
                    _buildResponsiveCategoryChip(context, 'SWITCH', screenWidth),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Encabezado
              const Text(
                'Bienvenido a LevelUp Shop',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center, // Centrar el texto
              ),
              const SizedBox(height: 16),
              const Text(
                'Encuentra los mejores videojuegos y accesorios para todas las plataformas.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center, // Centrar el texto
              ),
              const SizedBox(height: 32),

              // Productos populares
              const Text(
                'Productos Populares',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ), // Alineado a la izquierda
              ),
              const SizedBox(height: 16),
              _buildPopularProductsSection(context),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir un botón de categoría responsivo
  Widget _buildResponsiveCategoryChip(BuildContext context, String category, double screenWidth) {
    // Ajustar el ancho del botón según el tamaño de la pantalla
    final buttonWidth = screenWidth < 400 ? (screenWidth / 2) - 24 : 120;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: buttonWidth.toDouble(), // Ancho mínimo del botón
        maxWidth: buttonWidth.toDouble(), // Ancho máximo del botón
      ),
      child: ElevatedButton(
        onPressed: () {
          // Navegar a la categoría con el parámetro dinámico
          context.go('/category/$category'); // Incluir el parámetro dinámico en la URL
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        child: Text(
          category,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center, // Centrar el texto
        ),
      ),
    );
  }

  // Sección de productos populares
  Widget _buildPopularProductsSection(BuildContext context) {
    return FutureBuilder<List<Game>>(
      future: GamesService().fetchGames(), // Obtener todos los juegos
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
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron juegos populares.',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          // Seleccionar 5 juegos aleatorios
          final random = Random();
          final popularGames = (snapshot.data!..shuffle(random)).take(5).toList();

          return Center(
            child: SizedBox(
              height: 300, // Altura fija para la lista horizontal
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: popularGames.length,
                itemBuilder: (context, index) {
                  final game = popularGames[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0), // Espaciado horizontal
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // Centrar contenido horizontalmente
                      children: [
                        AspectRatio(
                          aspectRatio: 1.5,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                            child: Image.network(
                              game.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.error, color: Colors.red, size: 50),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center, // Centrar contenido horizontalmente
                            children: [
                              Text(
                                game.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center, // Centrar texto
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${game.precio.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center, // Centrar texto
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}