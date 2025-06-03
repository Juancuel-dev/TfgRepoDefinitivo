import 'package:flutter/material.dart';
import 'package:flutter_auth_app/services/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_app/services/cart_provider.dart';
import 'package:flutter_auth_app/services/auth_service.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'package:flutter_auth_app/services/cart_service.dart';

class OrderConfirmationPage extends StatefulWidget {
  const OrderConfirmationPage({super.key});

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  // Clave global para el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  // Estado para controlar si el formulario fue enviado correctamente
  final ValueNotifier<bool> _isFormSubmitted = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _isFormSubmitted.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Si el formulario es válido, cambiar el estado para mostrar el "tick verde"
      _isFormSubmitted.value = true;
    }
  }

  Future<void> _handleOrderConfirmation(
    BuildContext context,
    CartProvider cartProvider,
    String jwtToken,
    String clientId,
  ) async {
    
    print('JWT Token: $jwtToken');
    print('Client ID: $clientId');
    print('Items en el carrito: ${cartProvider.items}');

    if (jwtToken.isEmpty || clientId.isEmpty || cartProvider.items.isEmpty) {
      print('Error: Datos inválidos para confirmar el pedido');
      return;
    }

    final cartService = CartService();

    // Mostrar un indicador de carga mientras se procesa el pedido
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Intentar crear el pedido
    final success = await cartService.createOrders(
      items: cartProvider.items,
      jwtToken: jwtToken,
      clientId: clientId,
    );

    // Cerrar el indicador de carga
    Navigator.of(context).pop();

    // Imprimir la respuesta del servidor
    print('Respuesta del servidor: ${cartService.lastResponseBody}');

    if (success) {
      // Pedido creado con éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido confirmado y registrado correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
      cartProvider.clear(); // Vaciar el carrito después del pedido
      context.go('/'); // Redirigir a la página principal
    } else {
      // Error al crear el pedido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al registrar el pedido. Inténtalo de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final jwtToken = Provider.of<AuthProvider>(context, listen: false).jwtToken;

    // Verificar si el token JWT está disponible
    if (jwtToken == null || jwtToken.isEmpty) {
      print('Token JWT no disponible. Redirigiendo a /login...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login'); // Redirige a la página de inicio de sesión si no hay token
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Muestra un indicador de carga mientras redirige
        ),
      );
    }

    final clientId = AuthService().getClaimFromToken(jwtToken, 'clientId') ?? '';
    final userName = AuthService().getClaimFromToken(jwtToken, 'username') ?? 'Nombre de usuario no disponible';

    // Calcular IVA (21%)
    final iva = cartProvider.totalPrice * 0.21;
    final totalConIva = cartProvider.totalPrice + iva;

    return BaseLayout(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirmación de Pedido',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              // Información del usuario
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información del Usuario',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Username: $userName',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Resumen del pedido
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen del Pedido',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartProvider.items.length,
                      itemBuilder: (context, index) {
                        final item = cartProvider.items[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  item.game.imageUrl,
                                  width: 60,
                                  height: 60,
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Cantidad: ${item.quantity}',
                                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Subtotal: \$${(item.game.precio * item.quantity).toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 14, color: Colors.greenAccent),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'IVA (21%): \$${iva.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: \$${totalConIva.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Formulario de métodos de pago
              ValueListenableBuilder<bool>(
                valueListenable: _isFormSubmitted,
                builder: (context, isSubmitted, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: isSubmitted
                        ? const Icon(
                            Icons.check_circle,
                            key: ValueKey('tick'),
                            color: Colors.green,
                            size: 100,
                          )
                        : Form(
                            key: _formKey,
                            child: Container(
                              key: const ValueKey('form'),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Métodos de Pago',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 16),
                                  // Número de tarjeta
                                  TextFormField(
                                    controller: _cardNumberController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[800],
                                      hintText: 'Número de tarjeta',
                                      hintStyle: const TextStyle(color: Colors.white70),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.number,
                                    maxLength: 16,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'El número de tarjeta no puede estar vacío';
                                      }
                                      if (value.length != 16) {
                                        return 'El número de tarjeta debe tener 16 dígitos';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Fecha de expiración
                                  TextFormField(
                                    controller: _expiryDateController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[800],
                                      hintText: 'MM/AA',
                                      hintStyle: const TextStyle(color: Colors.white70),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.datetime,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'La fecha de expiración no puede estar vacía';
                                      }
                                      final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                                      if (!regex.hasMatch(value)) {
                                        return 'Formato inválido. Usa MM/AA';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // CVC
                                  TextFormField(
                                    controller: _cvvController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[800],
                                      hintText: 'CVC',
                                      hintStyle: const TextStyle(color: Colors.white70),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.number,
                                    maxLength: 3,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'El CVC no puede estar vacío';
                                      }
                                      if (value.length != 3) {
                                        return 'El CVC debe tener 3 dígitos';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  // Botón para validar los datos de la tarjeta
                                  ElevatedButton(
                                    onPressed: _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    child: const Text('Validar Tarjeta'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Botón de confirmación
              ElevatedButton(
                onPressed: () async {
                  if (!_isFormSubmitted.value) {
                    // Mostrar un mensaje si los datos de la tarjeta no han sido validados
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, valida los datos de la tarjeta antes de pagar.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  print('Confirmando pedido...');
                  await _handleOrderConfirmation(context, cartProvider, jwtToken, clientId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Pagar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}