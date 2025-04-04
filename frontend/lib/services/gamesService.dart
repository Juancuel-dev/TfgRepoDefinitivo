import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_auth_app/models/game.dart';

class GamesService {
  final String apiUrl = 'http://localhost:8080/gateway/games';

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
}