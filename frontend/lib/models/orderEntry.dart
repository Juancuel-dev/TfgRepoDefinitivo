import 'cart.dart';

class OrderEntry {
  final String? id;
  final String? orderId;
  final String? clientId;
  final double? precio;
  final DateTime? fecha;
  final List<CartItem>? games;

  OrderEntry({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.precio,
    required this.fecha,
    required this.games,
  });

  // Método para convertir un JSON en un objeto OrderEntry
  factory OrderEntry.fromJson(Map<String, dynamic> json) {
    return OrderEntry(
      id: json['id'],
      orderId: json['orderId'],
      clientId: json['clientId'],
      precio: json['precio'].toDouble(),
      fecha: DateTime.parse(json['fecha']),
      games: (json['games'] as List<dynamic>)
          .map((game) => CartItem.fromJson(game))
          .toList(),
    );
  }

  // Método para convertir un objeto OrderEntry a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'clientId': clientId,
      'precio': precio,
      'fecha': fecha!.toIso8601String(),
      'games': games!.map((game) => game.toJson()).toList(),
    };
  }
}