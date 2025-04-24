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
              // Categorías principales
              Center(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Encuentra los mejores videojuegos y accesorios para todas las plataformas.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Productos populares
              const Text(
                'Productos Populares',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildPopularProductsSection(context),

              const SizedBox(height: 32),

              // Juegos en oferta
              const Text(
                'Juegos en Oferta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildDiscountedGamesSection(context),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir un botón de categoría responsivo
  Widget _buildResponsiveCategoryChip(BuildContext context, String category, double screenWidth) {
    final buttonWidth = screenWidth < 400 ? (screenWidth / 2) - 24 : 120;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: buttonWidth.toDouble(),
        maxWidth: buttonWidth.toDouble(),
      ),
      child: ElevatedButton(
        onPressed: () {
          context.go('/category/$category');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        child: Text(
          category,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Sección de productos populares
  Widget _buildPopularProductsSection(BuildContext context) {
    return FutureBuilder<List<Game>>(
      future: GamesService().fetchGames(),
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
          final random = Random();
          final popularGames = (snapshot.data!..shuffle(random)).take(5).toList();

          return Center(
            child: SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: popularGames.length,
                itemBuilder: (context, index) {
                  final game = popularGames[index];
                  return InkWell(
                    onTap: () {
                      context.go(
                        '/details',
                        extra: game, // Pasar el objeto Game como argumento
                      );
                    },
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${game.precio.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  // Método para construir la sección de juegos en oferta
  Widget _buildDiscountedGamesSection(BuildContext context) {
    return FutureBuilder<List<Game>>(
      future: GamesService().fetchDiscountedGames(),
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
              'No hay juegos en oferta.',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          // Limitar la lista de juegos a un máximo de 20
          final games = snapshot.data!.take(20).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              // Calcular dinámicamente el número de columnas según el ancho disponible
              final crossAxisCount = constraints.maxWidth ~/ 200; // Cada tarjeta ocupa 200px de ancho
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // Número de columnas dinámico
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.75, // Proporción de las tarjetas
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  final originalPrice = (game.precio / (1 - (15 + Random().nextInt(36)) / 100)).toStringAsFixed(2);
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        context.go(
                          '/details',
                          extra: game,
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  game.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '\$$originalPrice',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '\$${game.precio.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}