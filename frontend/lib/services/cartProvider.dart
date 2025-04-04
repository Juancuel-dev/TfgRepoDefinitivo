// filepath: /lib/models/cart_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/cart.dart';

class CartProvider extends ChangeNotifier {
  final Cart _cart = Cart();

  Cart get cart => _cart;

  void addItem(item) {
    _cart.addItem(item);
    notifyListeners();
  }

  void removeItem(item) {
    _cart.removeItem(item);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}