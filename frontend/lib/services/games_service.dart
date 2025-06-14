import 'dart:convert';
import 'dart:math';
import 'package:flutter_auth_app/config/server_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_auth_app/models/game.dart';

class GamesService {
  final String apiUrl = '${ServerConfig.serverIp}/gateway/games';

  Future<List<Game>> fetchGames() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Decodificar como UTF-8
      final body = utf8.decode(response.bodyBytes);
      List<dynamic> data = jsonDecode(body);
      return data.map((dynamic item) => Game.fromJson(item)).toList();
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
      // Decodificar como UTF-8
      final body = utf8.decode(response.bodyBytes);
      List<dynamic> data = jsonDecode(body);
      return data.map((dynamic item) => Game.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load games for category $consola');
    }
  }

  Future<List<Game>> searchGames(String query) async {
    final url = Uri.parse('${ServerConfig.serverIp}/gateway/games/search?name=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decodificar como UTF-8
      final body = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(body);
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
      // Decodificar como UTF-8
      final body = utf8.decode(response.bodyBytes);
      List<dynamic> data = jsonDecode(body);
      List<Game> games = data.map((dynamic item) => Game.fromJson(item)).toList();
        
      // Mezclar los juegos en un orden aleatorio
      games.shuffle(Random());

      // primeros 20 juegos
      return games.take(20).toList();
    } else {
      throw Exception('Failed to load discounted games');
    }
  }

  Future<List<Game>> fetchGamesLimit(int limit) async {
    final response = await http.get(
      Uri.parse('$apiUrl?limit=$limit'), // parámetro de límite a la URL
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Decodificar como UTF-8
      final body = utf8.decode(response.bodyBytes);
      List<dynamic> data = jsonDecode(body);
      return data.map((dynamic item) => Game.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load games with limit $limit');
    }
  }
}