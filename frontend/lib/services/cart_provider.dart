// filepath: /lib/models/cart_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/cart.dart';
import 'package:flutter_auth_app/models/game.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  String? _jwtToken; // Propiedad para almacenar el token JWT

  /// Getter para obtener los elementos del carrito
  List<CartItem> get items => List.unmodifiable(_items);

  /// Getter para calcular el precio total del carrito
  double get totalPrice =>
      _items.fold(0, (total, item) => total + (item.game.precio * item.quantity));

  /// Getter para obtener el token JWT
  String? get jwtToken => _jwtToken;

  /// Setter para configurar el token JWT
  void setJwtToken(String token) {
    _jwtToken = token;
    notifyListeners();
  }

  /// Agrega un juego al carrito
  void addToCart(Game game) {
    // Verificar si el juego ya está en el carrito
    final existingItemIndex = _items.indexWhere((item) => item.game.id == game.id);

    if (existingItemIndex != -1) {
      // Si el juego ya está en el carrito, aumentar la cantidad
      _items[existingItemIndex] =
          CartItem(game: _items[existingItemIndex].game, quantity: _items[existingItemIndex].quantity + 1);
    } else {
      // Si el juego no está en el carrito, agregarlo como una nueva entrada
      _items.add(CartItem(game: game, quantity: 1));
    }

    notifyListeners();
  }

  /// Elimina un juego del carrito
  void removeFromCart(Game game) {
    _items.removeWhere((item) => item.game.id == game.id);
    notifyListeners();
  }

  /// Vacía el carrito
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Obtiene la cantidad total de artículos en el carrito
  int get totalItems => _items.fold(0, (total, item) => total + item.quantity);
}