import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_auth_app/models/game.dart';

class GamesService {
  final String apiUrl = 'http://localhost:8080/games';

  Future<List<Game>> fetchGames(String token) async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
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
}