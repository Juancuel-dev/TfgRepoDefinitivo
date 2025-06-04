import 'dart:convert';
import 'package:flutter_auth_app/config/server_config.dart';
import 'package:flutter_auth_app/models/cart.dart';
import 'package:flutter_auth_app/services/auth_service.dart';
import 'package:http/http.dart' as http;

class CartService {
  String? lastResponseBody; // Almacena la última respuesta del servidor

  CartService();

  Future<bool> createOrder({
    required String orderId,
    required List<CartItem> games,
    required double precio,
    required DateTime fecha,
    required String jwtToken,
    required String clientId,
  }) async {
    final url = Uri.parse('${ServerConfig.serverIp}/gateway/orders');

    final gamesJson = games.map((item) => {
      'game': {
        'name': item.game.name, 
        'precio': item.game.precio,
        'metacritic': item.game.metacritic,
        'consola': item.game.consola,
      },
      'quantity': item.quantity,
    }).toList();

    final body = {
      "orderId": orderId,
      "clientId": clientId,
      "precio": precio,
      "fecha": fecha.toIso8601String(),
      "games": gamesJson, 
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $jwtToken",
        },
        body: jsonEncode(body),
      );

      // Almacenar la respuesta del servidor
      lastResponseBody = response.body;

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> createOrders({
    required List<CartItem> items,
    required String jwtToken,
    required String clientId,
  }) async {
    final clientId = AuthService().getClaimFromToken(jwtToken, 'clientId') ?? '';
    if (clientId.isEmpty) {
      return false;
    }

    final orderId = '${DateTime.now().millisecondsSinceEpoch}';
    
    final totalprecio = items.fold(0.0, (sum, item) => sum + (item.game.precio * item.quantity));

    return await createOrder(
      orderId: orderId,
      games: items,
      precio: totalprecio,
      fecha: DateTime.now(),
      jwtToken: jwtToken,
      clientId: clientId,
    );
  }
}