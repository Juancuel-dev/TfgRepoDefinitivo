import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/services/games_service.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      showBackButton: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              


              // Juego destacado
              _buildFeaturedGameSection(context),

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


  // Método para construir la sección de juego destacado
  Widget _buildFeaturedGameSection(BuildContext context) {
    return FutureBuilder<List<Game>>(
      future: GamesService().fetchDiscountedGames(), // Obtener juegos en oferta
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
              'No se encontraron juegos en oferta.',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          final random = Random();
          final featuredGame = snapshot.data![random.nextInt(snapshot.data!.length)]; // Seleccionar un juego aleatorio
          final originalPrice = (featuredGame.precio / (1 - (15 + random.nextInt(36)) / 100)).toStringAsFixed(2);

          return Stack(
            children: [
              // Imagen de fondo
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  featuredGame.imageUrl,
                  height: 350, // Ajustar la altura de la imagen
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error, color: Colors.red, size: 50),
                    );
                  },
                ),
              ),
              // Contenido superpuesto
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      featuredGame.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$$originalPrice',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${featuredGame.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.go(
                          '/details',
                          extra: featuredGame, // Pasar el objeto Game como argumento
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Ver Detalles',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
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
          final games = snapshot.data!.take(9).toList(); // Limitar a 9 juegos
          final isMobile = MediaQuery.of(context).size.width < 600;

          if (isMobile) {
            // Diseño para dispositivos móviles: fila deslizable
            return SizedBox(
              height: 150, // Altura de las tarjetas
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return Container(
                    width: 120, // Ancho de cada tarjeta
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        context.go(
                          '/details',
                          extra: game, // Pasar el objeto Game como argumento
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
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${game.precio.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
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
            );
          } else {
            // Diseño para pantallas grandes: grid 3x3 con mucho padding
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(64.0), // Mucho padding alrededor
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Desactivar scroll interno
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Tres columnas
                    crossAxisSpacing: 32.0, // Espaciado horizontal entre tarjetas
                    mainAxisSpacing: 32.0, // Espaciado vertical entre tarjetas
                    childAspectRatio: 0.75, // Proporción de las tarjetas
                  ),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                      ),
                      child: InkWell(
                        onTap: () {
                          context.go(
                            '/details',
                            extra: game, // Pasar el objeto Game como argumento
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
                              padding: const EdgeInsets.all(8.0), // Espaciado interno
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    game.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${game.precio.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
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
          final games = snapshot.data!;
          final ScrollController scrollController = ScrollController();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 300, // Altura de las tarjetas
                child: Stack(
                  children: [
                    // Lista horizontal de juegos
                    ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        final originalPrice = (game.precio / (1 - (15 + Random().nextInt(36)) / 100)).toStringAsFixed(2);

                        return Container(
                          width: 200, // Ancho de cada tarjeta
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
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
                    ),

                    // Flecha izquierda
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () {
                          scrollController.animateTo(
                            scrollController.offset - 220, // Desplazar hacia atrás
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),

                    // Flecha derecha
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onPressed: () {
                          scrollController.animateTo(
                            scrollController.offset + 220, // Desplazar hacia adelante
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}