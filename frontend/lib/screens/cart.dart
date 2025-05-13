import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_auth_app/config/server_config.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_app/services/cart_provider.dart';
import 'package:flutter_auth_app/services/cart_service.dart';
import 'package:flutter_auth_app/services/auth_provider.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  /// Decodifica el JWT y extrae el clientId
  String _extractClientId(String jwtToken) {
    final parts = jwtToken.split('.');
    if (parts.length != 3) {
      throw Exception('Token JWT inválido');
    }

    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final payloadMap = json.decode(payload) as Map<String, dynamic>;

    if (!payloadMap.containsKey('clientId')) {
      throw Exception('El token JWT no contiene clientId');
    }

    return payloadMap['clientId'];
  }

  Future<void> _purchase(BuildContext context) async {
    final cartItems = Provider.of<CartProvider>(context, listen: false).items;
    final jwtToken = Provider.of<AuthProvider>(context, listen: false).jwtToken;
    final cartService = CartService(baseUrl: '${ServerConfig.serverIp}');

    // Verificar si el carrito está vacío
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El carrito está vacío. Añade productos antes de realizar un pedido.'),
          duration: Duration(seconds: 1), // Duración ajustada a 1 segundo
        ),
      );
      return;
    }

    if (jwtToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No estás autenticado. Inicia sesión para continuar.'),
          duration: Duration(seconds: 1), // Duración ajustada a 1 segundo
        ),
      );
      return;
    }

    // Extraer el clientId del JWT
    late String clientId;
    try {
      clientId = _extractClientId(jwtToken);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al extraer clientId: $e'),
          duration: const Duration(seconds: 1), // Duración ajustada a 1 segundo
        ),
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
      final success = await cartService.createOrders(
        items: cartItems,
        jwtToken: jwtToken,
        clientId: clientId, // Pasar el clientId extraído
      );

      Navigator.pop(context);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al realizar el pedido. Inténtalo de nuevo.'),
            duration: Duration(seconds: 1), // Duración ajustada a 1 segundo
          ),
        );
        return;
      }

      Provider.of<CartProvider>(context, listen: false).clear(); // Vaciar el carrito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compra realizada con éxito'),
          duration: Duration(seconds: 1), // Duración ajustada a 1 segundo
        ),
      );
      context.go('/'); // Navegación con GoRouter
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al realizar el pedido: $e'),
          duration: const Duration(seconds: 1), // Duración ajustada a 1 segundo
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = Provider.of<CartProvider>(context).items;

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
        ),
      ),
    );
  }
}