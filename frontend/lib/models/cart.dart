import 'package:flutter_auth_app/models/game.dart';

class CartItem {
  final Game game;
  int quantity;

  CartItem({required this.game, this.quantity = 1});
}

class Cart {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(Game game) {
    for (var item in _items) {
      if (item.game.name == game.name) {
        item.quantity++;
        return;
      }
    }
    _items.add(CartItem(game: game));
  }

  void clear() {
    _items.clear();
  }

  double get totalPrice {
    return _items.fold(0, (total, item) => total + item.game.precio * item.quantity);
  }
}