import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/services/gamesService.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';
import 'package:go_router/go_router.dart'; // Importar GoRouter para la navegación

class CategoryPage extends StatefulWidget {
  final String category;

  const CategoryPage({super.key, required this.category});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<Game>> futureGames;

  @override
  void initState() {
    super.initState();
    // Llamar al backend para obtener los juegos filtrados por categoría
    futureGames = GamesService().fetchGamesByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseLayout(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la categoría
              Text(
                'Categoría: ${widget.category}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Lista de juegos filtrados
              Expanded(
                child: FutureBuilder<List<Game>>(
                  future: futureGames,
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
                          'No se encontraron juegos para esta categoría',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth < 600
                              ? 2
                              : constraints.maxWidth < 900
                                  ? 3
                                  : 5;

                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final game = snapshot.data![index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // Navegar a la página de detalles del juego usando GoRouter
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
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '\$${game.precio.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Colors.greenAccent,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Metacritic: ${game.metacritic}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
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
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}