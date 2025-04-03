import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/screens/categorypage.dart';
import 'package:flutter_auth_app/screens/details.dart';
import 'package:flutter_auth_app/services/gamesService.dart';
import 'package:flutter_auth_app/models/cart.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';
import 'package:flutter_auth_app/screens/login.dart';
import 'package:flutter_auth_app/screens/adminPanel.dart'; // Página de administración
import 'package:jwt_decoder/jwt_decoder.dart'; // Para decodificar el token

class HomePage extends StatefulWidget {
  final Cart cart;
  final String? token; // Token será null si el usuario no está autenticado

  const HomePage({super.key, required this.cart, this.token});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Game> games = [];
  int currentPage = 1;
  int totalPages = 10; // Cambia esto según el número total de páginas disponibles en tu backend
  bool isLoading = false;
  String? token;
  bool isAdmin = false; // Variable para verificar si el usuario es admin

  @override
  void initState() {
    super.initState();
    token = widget.token; // Inicializar el token con el valor del widget
    _loadGames(currentPage);

    // Verificar si el token es válido
    if (token != null && token!.isNotEmpty) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
        if (decodedToken['role'] == 'admin') {
          setState(() {
            isAdmin = true;
          });
        }
      } catch (e) {
        // Manejar el caso de un token inválido
        print('Error al decodificar el token: $e');
        token = null; // Invalidar el token
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(
                cart: widget.cart,
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

  Future<void> _loadGames(int page) async {
    setState(() {
      isLoading = true;
    });

    try {
      final newGames = await GamesService().fetchGames(page: page);
      setState(() {
        games = newGames;
        currentPage = page;
      });
    } catch (e) {
      print('Error al cargar juegos: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseLayout(
        cart: widget.cart,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Row de categorías
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryChip('PC'),
                  _buildCategoryChip('XBOX'),
                  _buildCategoryChip('PS5'),
                  _buildCategoryChip('SWITCH'),
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
                        builder: (context) => AdminPanel(cart: widget.cart),
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
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : games.isEmpty
                        ? const Center(
                            child: Text(
                              'No se encontraron juegos',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: 0.75,
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GameDetailPage(game: game, cart: widget.cart),
                                      ),
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
                          ),
              ),
              const SizedBox(height: 16),
              // Control de paginación
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages, (index) {
                  final page = index + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: currentPage == page
                          ? null
                          : () {
                              _loadGames(page);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentPage == page ? Colors.blueGrey : Colors.grey,
                      ),
                      child: Text(
                        '$page',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir un botón de categoría
  Widget _buildCategoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPage(category: category, cart: widget.cart),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(
          category,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}