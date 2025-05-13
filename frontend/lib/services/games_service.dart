import 'dart:convert';
import 'dart:math';
import 'package:flutter_auth_app/config/server_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_auth_app/models/game.dart';

class GamesService {
  final String apiUrl = '${ServerConfig.serverIp}/gateway/games';

  Future<List<Game>> fetchGames() async {
    final response = await http.get(
      Uri.parse(apiUrl), // Agregar el número de página a la URL
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Game> games = body.map((dynamic item) => Game.fromJson(item)).toList();
      return games;
    } else {
      throw Exception('Failed to load games');
    }
  }

  Future<List<Game>> fetchGamesByCategory(String consola) async {
    final response = await http.get(
      Uri.parse('$apiUrl/consola/$consola'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Game> games = body.map((dynamic item) => Game.fromJson(item)).toList();
      return games;
    } else {
      throw Exception('Failed to load games for category $consola');
    }
  }

  Future<List<Game>> searchGames(String query) async {
    final url = Uri.parse('${ServerConfig.serverIp}/gateway/games/search?name=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Game.fromJson(json)).toList();
    } else {
      throw Exception('Error al buscar juegos');
    }
  }

  Future<List<Game>> fetchDiscountedGames() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Game> games = body.map((dynamic item) {
        Game game = Game.fromJson(item);
        // Generar un descuento aleatorio entre 15% y 50%
        final random = Random();
        final discountPercentage = 15 + random.nextInt(36); // 15% a 50%
        game.precio = (game.precio * (1 - discountPercentage / 100)).toDouble();
        return game;
      }).toList();

      // Mezclar los juegos en un orden aleatorio
      games.shuffle(Random());

      // Tomar los primeros 20 juegos
      return games.take(20).toList();
    } else {
      throw Exception('Failed to load discounted games');
    }
  }
}