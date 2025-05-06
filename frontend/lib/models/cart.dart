import 'package:flutter_auth_app/models/game.dart';

class CartItem {
  final Game game;
  int quantity;

  CartItem({required this.game, required this.quantity});

  // Método para convertir un JSON en un objeto CartItem
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      game: Game.fromJson(json['game']), // Convertir el JSON del juego a un objeto Game
      quantity: json['quantity'],
    );
  }

  // Método para convertir un objeto CartItem a JSON
  Map<String, dynamic> toJson() {
    return {
      'game': game.toJson(), // Convertir el objeto Game a JSON
      'quantity': quantity,
    };
  }
}

class Cart {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(CartItem item) {
    // Lógica para agregar un elemento al carrito
    _items.add(item);
  }

  void removeItem(CartItem item) {
    // Lógica para eliminar un elemento del carrito
    _items.remove(item);
  }

  void clear() {
    // Lógica para vaciar el carrito
    _items.clear();
  }

  double get totalPrice {
    // Calcular el precio total del carrito
    return _items.fold(0, (total, item) => total + (item.game.precio * item.quantity));
  }
}