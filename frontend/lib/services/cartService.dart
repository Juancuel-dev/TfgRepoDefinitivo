import 'dart:convert';
import 'package:flutter_auth_app/models/cart.dart';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl;

  CartService({required this.baseUrl});

  /// Realiza un pedido enviando los datos al backend
  Future<bool> createOrder({
    required String orderId,
    required String userId,
    required String gameId,
    required String precio,
    required DateTime fecha,
    required String jwtToken, // Token JWT para autenticación
  }) async {
    final url = Uri.parse('$baseUrl/gateway/orders');

    final body = {
      "orderId": orderId,
      "userId": userId,
      "gameId": gameId,
      "precio": precio,
      "fecha": fecha.toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $jwtToken", // Agregar el token JWT al encabezado
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        // Pedido creado exitosamente
        return true;
      } else {
        // Manejo de errores
        print('Error al crear el pedido: ${response.body}');
        return false;
      }
    } catch (e) {
      // Manejo de errores de red
      print('Error de red al crear el pedido: $e');
      return false;
    }
  }

  /// Desglosa la lista de juegos y envía una petición por cada uno
  Future<bool> createOrders({
    required String userId,
    required List<CartItem> items,
    required String jwtToken,
  }) async {
    for (final item in items) {
      final success = await createOrder(
        orderId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        gameId: item.game.id,
        precio: item.game.precio.toStringAsFixed(2), // Usar el precio original del juego
        fecha: DateTime.now(),
        jwtToken: jwtToken,
      );

      if (!success) {
        return false; // Detener si algún pedido falla
      }
    }
    return true; // Todos los pedidos fueron exitosos
  }
}