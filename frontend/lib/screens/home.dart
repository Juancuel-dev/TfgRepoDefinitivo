import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/screens/categorypage.dart';
import 'package:flutter_auth_app/screens/login.dart';
import 'package:flutter_auth_app/services/gamesService.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';
import 'package:flutter_auth_app/screens/details.dart';
import 'package:flutter_auth_app/screens/adminPanel.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HomePage extends StatefulWidget {
  final String? token;

  const HomePage({super.key, this.token});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Game>> futureGames;
  String? token;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    token = widget.token;
    futureGames = GamesService().fetchGames(); // Cargar todos los juegos

    if (token != null && token!.isNotEmpty) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
        if (decodedToken['role'] == 'ADMIN') {
          setState(() {
            isAdmin = true;
          });
        }
      } catch (e) {
        print('Error al decodificar el token: $e');
        token = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(
                onLogin: (newToken) {
                  setState(() {
                    token = newToken;
                  });
                },
              ),
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BaseLayout(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.0, // Espaciado horizontal entre los botones
                  runSpacing: 8.0, // Espaciado vertical entre filas
                  alignment: WrapAlignment.center,
                  children: [
                    _buildResponsiveCategoryChip('PC', screenWidth),
                    _buildResponsiveCategoryChip('XBOX', screenWidth),
                    _buildResponsiveCategoryChip('PS5', screenWidth),
                    _buildResponsiveCategoryChip('SWITCH', screenWidth),
                  ],
                ),
                const SizedBox(height: 16),
                // Mostrar botón de administración si el usuario es admin
                if (isAdmin)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminPanel(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Panel de Administración'),
                  ),
                const SizedBox(height: 16),
                // Lista de juegos
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
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
                            'No se encontraron juegos',
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
                                childAspectRatio: 0.7, // Ajustar el aspecto para evitar overflow
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => GameDetailPage(
                                            game: game,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 1.5, // Mantener proporción de la imagen
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
                                                  fontSize: 16, // Ajustar tamaño de texto
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis, // Evitar overflow del texto
                                                maxLines: 1,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '\$${game.precio.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: Colors.greenAccent,
                                                  fontSize: 14, // Ajustar tamaño de texto
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Metacritic: ${game.metacritic}',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12, // Ajustar tamaño de texto
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
      ),
    );
  }

  // Método para construir un botón de categoría responsivo
  Widget _buildResponsiveCategoryChip(String category, double screenWidth) {
    // Ajustar el ancho del botón según el tamaño de la pantalla
    final buttonWidth = screenWidth < 400 ? (screenWidth / 2) - 24 : 120;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: buttonWidth.toDouble(), // Ancho mínimo del botón
        maxWidth: buttonWidth.toDouble(), // Ancho máximo del botón
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPage(category: category),
            ),
          );
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
}