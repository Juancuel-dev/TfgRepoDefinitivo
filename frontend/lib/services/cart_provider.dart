import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/cart.dart';
import 'package:flutter_auth_app/models/game.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  String? _jwtToken; 

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalPrice =>
      _items.fold(0, (total, item) => total + (item.game.precio * item.quantity));

  String? get jwtToken => _jwtToken;

  void setJwtToken(String token) {
    _jwtToken = token;
    notifyListeners();
  }

  void addToCart(Game game) {
    
    final existingItemIndex = _items.indexWhere((item) => item.game.id == game.id);

    if (existingItemIndex != -1) {
      
      _items[existingItemIndex] =
          CartItem(game: _items[existingItemIndex].game, quantity: _items[existingItemIndex].quantity + 1);
    } else {
      
      _items.add(CartItem(game: game, quantity: 1));
    }

    notifyListeners();
  }

  void removeFromCart(Game game) {
    _items.removeWhere((item) => item.game.id == game.id);
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int get totalItems => _items.fold(0, (total, item) => total + item.quantity);
}