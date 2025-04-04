import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_auth_app/services/cartProvider.dart';
import 'package:flutter_auth_app/services/cartService.dart';
import 'package:flutter_auth_app/services/authProvider.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';
import 'package:flutter_auth_app/screens/home.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> _purchase(BuildContext context) async {
    final cartItems = Provider.of<CartProvider>(context, listen: false).items; // Cambiado de `cart` a `items`
    final jwtToken = Provider.of<AuthProvider>(context, listen: false).jwtToken;
    final cartService = CartService(baseUrl: 'http://localhost:8080');

    if (jwtToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No estás autenticado. Inicia sesión para continuar.')),
      );
      return;
    }

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      for (final item in cartItems) {
        final success = await cartService.createOrder(
          orderId: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'user123', // Cambia esto según tu lógica
          gameId: item.game.id,
          precio: item.game.precio.toStringAsFixed(2), // Usar el precio original del juego
          fecha: DateTime.now(),
          jwtToken: jwtToken, // Pasar el token JWT
        );

        if (!success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al realizar el pedido. Inténtalo de nuevo.')),
          );
          return;
        }
      }

      Provider.of<CartProvider>(context, listen: false).clear(); // Vaciar el carrito
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra realizada con éxito')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al realizar el pedido: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = Provider.of<CartProvider>(context).items; // Cambiado de `cart` a `items`

    return BaseLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Carrito de Compras',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: cartItems.isEmpty
                  ? const Center(
                      child: Text(
                        'Tu carrito está vacío',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              // Imagen del juego (si está disponible)
                              if (item.game.imageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    item.game.imageUrl!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
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
                                      'Precio: \$${item.game.precio.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16, color: Colors.greenAccent),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Subtotal: \$${(item.game.precio * item.quantity).toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16, color: Colors.white),
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
              'Total: \$${Provider.of<CartProvider>(context).totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
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
        ),      ),    );  }}