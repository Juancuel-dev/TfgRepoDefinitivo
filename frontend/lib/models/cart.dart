import 'package:flutter_auth_app/models/game.dart';

class CartItem {
  final Game game;
  int quantity;

  CartItem({required this.game, required this.quantity});
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