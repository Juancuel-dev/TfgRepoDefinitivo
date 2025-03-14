import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/cart.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';
import 'package:flutter_auth_app/screens/home.dart';

class CartPage extends StatelessWidget {
  final Cart cart;
  final String token;

  CartPage({required this.cart, required this.token});

  void _purchase(BuildContext context) {
    cart.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Compra realizada con éxito')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(cart: cart, token: token)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      cart: cart,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Carrito de Compras', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return ListTile(
                    title: Text(item.game.name),
                    subtitle: Text('Cantidad: ${item.quantity}'),
                    trailing: Text('Precio: \$${(item.game.precio * item.quantity).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text('Total: \$${cart.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _purchase(context),
              child: const Text('Comprar'),
            ),
          ],
        ),
      ),
    );
  }
}