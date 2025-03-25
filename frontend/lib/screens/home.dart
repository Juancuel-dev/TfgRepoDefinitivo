import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/screens/details.dart';
import 'package:flutter_auth_app/services/gamesService.dart';
import 'package:flutter_auth_app/models/cart.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';

class HomePage extends StatefulWidget {
  final Cart cart;
  final String token;

  HomePage({required this.cart, required this.token});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Game>> futureGames;

  @override
  void initState() {
    super.initState();
    futureGames = GamesService().fetchGames();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      cart: widget.cart,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            // Body
            Expanded(
              child: FutureBuilder<List<Game>>(
                future: futureGames,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No se encontraron juegos', style: TextStyle(color: Colors.white)));
                  } else {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final game = snapshot.data![index];
                        return Card(
                          color: Colors.grey[850],
                          elevation: 4,
                          child: InkWell(
                            onTap: () {
                              // Navegar a la página de detalles del juego
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
                                  child: Image.network(
                                    game.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        game.name,
                                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '\$${game.precio.toStringAsFixed(2)}',
                                        style: TextStyle(color: Colors.greenAccent, fontSize: 16),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Metacritic: ${game.metacritic}',
                                        style: TextStyle(color: Colors.white70, fontSize: 14),
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
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}