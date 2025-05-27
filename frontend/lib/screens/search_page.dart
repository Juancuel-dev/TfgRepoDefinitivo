import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/services/games_service.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends StatefulWidget {
  final String searchQuery;

  const SearchPage({super.key, required this.searchQuery});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Game>> futureGames;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _loadGames(widget.searchQuery);
  }

  void _loadGames(String query) {
    setState(() {
      futureGames = GamesService().searchGames(query);
    });
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
              // Campo de búsqueda
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar juegos...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.greenAccent),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _loadGames(value.trim()); // Cargar los juegos con la nueva búsqueda
                  }
                },
              ),
              const SizedBox(height: 16),

              // Título de la búsqueda
              Text(
                'Resultados para: "${_searchController.text}"',
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
                          'No se encontraron juegos para esta búsqueda',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      final games = snapshot.data!;
                      final exactMatch = games.isNotEmpty && games.first.name.toLowerCase() == _searchController.text.trim().toLowerCase();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!exactMatch)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                'No hemos encontrado lo que buscas, pero te pueden interesar:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Ajustar dinámicamente el número de columnas
                                final crossAxisCount = constraints.maxWidth <= 405
                                    ? 1
                                    : (constraints.maxWidth > 405 && constraints.maxWidth <= 600)
                                        ? 2
                                        : (constraints.maxWidth > 600 && constraints.maxWidth <= 900)
                                            ? 3
                                            : 4;

                                // Calcular dinámicamente el childAspectRatio
                                final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
                                final cardHeight = cardWidth / 0.75; // Mantener la proporción original
                                final childAspectRatio = cardWidth / cardHeight;

                                return GridView.builder(
                                  padding: const EdgeInsets.only(top: 16), // Espaciado superior
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                    childAspectRatio: childAspectRatio, // Usar el aspecto dinámico
                                  ),
                                  itemCount: games.length,
                                  itemBuilder: (context, index) {
                                    final game = games[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[850],
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          final formattedName = game.name.replaceAll(' ', '-'); // Reemplazar espacios por guiones
                                          context.go('/details/$formattedName'); // Navegar a la página de detalles con el nombre formateado
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
                                                  Text(
                                                    '\$${game.precio.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      color: Colors.greenAccent,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Metacritic: ${game.metacritic}',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
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
                            ),
                          ),
                        ],
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