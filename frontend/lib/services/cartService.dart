import 'dart:convert';
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
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        // Pedido creado exitosamente
        return true;
      } else {
        // Error al crear el pedido
        print('Error al crear el pedido: ${response.body}');
        return false;
      }
    } catch (e) {
      // Manejo de errores de red
      print('Error de red al crear el pedido: $e');
      return false;
    }
  }
}