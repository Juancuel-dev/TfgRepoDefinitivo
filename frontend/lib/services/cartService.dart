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

    // Convertir los juegos a un formato que se pueda serializar
    final gamesJson = games.map((item) => {
      'gameId': item.game.id,
      'quantity': item.quantity,
      'precio': item.game.precio,
    }).toList();

    // Calcular el precio total basado en los items del carrito
    final totalprecio = games.fold(0.0, (sum, item) => sum + (item.game.precio * item.quantity));

    final body = {
      "orderId": orderId,
      "games": gamesJson,
      "precio": totalprecio,
      "fecha": fecha.toIso8601String(),
      "clientId": clientId,
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