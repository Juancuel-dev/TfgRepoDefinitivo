import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_app/services/cart_provider.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'package:logger/logger.dart'; 

class CartPage extends StatelessWidget {
  CartPage({super.key});

  final Logger _logger = Logger(
    level: Level.debug, 
    printer: PrettyPrinter(), 
  );

  @override
  Widget build(BuildContext context) {
    final cartItems = Provider.of<CartProvider>(context).items;

    _logger.i('Construyendo la pagina. Numero de items: ${cartItems.length}'); 

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
                        _logger.i('Renderizando item: ${item.game.name}, Cantidad: ${item.quantity}'); 

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  item.game.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
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
                                      'Precio: ${item.game.precio.toStringAsFixed(2)}€',
                                      style: const TextStyle(fontSize: 16, color: Colors.greenAccent),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Subtotal: ${(item.game.precio * item.quantity).toStringAsFixed(2)}€',
                                      style: const TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _logger.i('Eliminando item: ${item.game.name}'); 
                                  Provider.of<CartProvider>(context, listen: false).removeItem(item);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${item.game.name} eliminado del carrito.'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total: ${Provider.of<CartProvider>(context).totalPrice.toStringAsFixed(2)}€',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final cartItems = Provider.of<CartProvider>(context, listen: false).items;

                if (cartItems.isEmpty) {
                  _logger.w('Se ha intentado continuar con el carrito vacio'); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El carrito está vacío. Añade productos antes de continuar.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  return;
                }

                _logger.i('Confirmando pedido. Articulos: ${cartItems.length}'); 
                context.go('/order-confirmation');
              },
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