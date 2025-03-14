import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/screens/details.dart';
import 'package:flutter_auth_app/services/gamesService.dart';
import 'package:flutter_auth_app/models/cart.dart';

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
    futureGames = GamesService().fetchGames(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Games'),
      ),
      body: FutureBuilder<List<Game>>(
        future: futureGames,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No games found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final game = snapshot.data![index];
                return ListTile(
                  title: Text(game.name),
                  subtitle: Text('Price: \$${game.precio}, Metacritic: ${game.metacritic}'),
                  leading: Image.network(game.imageUrl),
                  onTap: () {
                    // Navegar a la página de detalles del juego
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameDetailPage(game: game, cart: widget.cart),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}