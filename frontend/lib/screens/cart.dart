import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/cart.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';
import 'package:flutter_auth_app/screens/home.dart';

class CartPage extends StatelessWidget {
  final Cart cart;
  final String token;

  const CartPage({super.key, required this.cart, required this.token});

  void _purchase(BuildContext context) {
    cart.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compra realizada con éxito')),
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
            // Título del carrito
            const Text(
              'Carrito de Compras',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Lista de elementos del carrito
            Expanded(
              child: cart.items.isEmpty
                  ? const Center(
                      child: Text(
                        'Tu carrito está vacío',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              // Imagen del juego
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 80,
                                  maxHeight: 80,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    item.game.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Detalles del juego
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.game.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Cantidad: ${item.quantity}',
                                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Precio: \$${(item.game.precio * item.quantity).toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16, color: Colors.greenAccent),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            // Total del carrito
            Text(
              'Total: \$${cart.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Botón de compra
            ElevatedButton(
              onPressed: () => _purchase(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Comprar'),
            ),
          ],
        ),
      ),
    );
  }
}