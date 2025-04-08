import 'dart:convert';
import 'package:flutter_auth_app/models/cart.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl;

  CartService({required this.baseUrl});

  /// Realiza un pedido enviando los datos al backend
  Future<bool> createOrder({
    required String orderId,
    required Map<Game,int> games,
    required String precio,
    required DateTime fecha,
    required String jwtToken, // Token JWT para autenticación
    required String clientId, // Agregar clientId como parámetro requerido
  }) async {
    final url = Uri.parse('$baseUrl/gateway/orders');

    final body = {
      "orderId": orderId,
      "games": games,
      "precio": precio,
      "fecha": fecha.toLocal(),
      "clientId": clientId, // Incluir clientId en el cuerpo de la petición
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
    required List<CartItem> items,
    required String jwtToken,
    required String clientId, // Agregar clientId como parámetro requerido
  }) async {
    // Generar un único orderId para toda la orden
    final orderId = '${DateTime.now().millisecondsSinceEpoch}';

      for (int i = 0; i < item.quantity; i++) { // Iterar según la cantidad de unidades
        final success = await createOrder(
          orderId: orderId,
          precio: item.game.precio.toStringAsFixed(2), // Usar el precio original del juego
          fecha: DateTime.now(),
          jwtToken: jwtToken,
          clientId: clientId, // Enviar el clientId
        );
    }
    return true; // Todos los pedidos fueron exitosos
  }
}