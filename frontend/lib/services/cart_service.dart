import 'dart:convert';
import 'package:flutter_auth_app/models/cart.dart';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl;

  CartService({required this.baseUrl});

  /// Realiza un pedido enviando los datos al backend
  Future<bool> createOrder({
    required String orderId,
    required List<CartItem> games,
    required double precio,
    required DateTime fecha,
    required String jwtToken,
    required String clientId,
  }) async {
    final url = Uri.parse('$baseUrl/gateway/orders');

    // Convertir los juegos a un formato que coincida con el backend
    final gamesJson = games.map((item) => {
      'game': {
        'name': item.game.name, // Asegúrate de que estos campos coincidan con GameDTO
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
      "games": gamesJson, // Enviar la lista de juegos con la estructura correcta
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

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Error al crear el pedido: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de red al crear el pedido: $e');
      return false;
    }
  }

  /// Crea una orden con todos los items del carrito
  Future<bool> createOrders({
    required List<CartItem> items,
    required String jwtToken,
    required String clientId,
  }) async {
    final orderId = '${DateTime.now().millisecondsSinceEpoch}';
    
    // Calcular el precio total de todos los items
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