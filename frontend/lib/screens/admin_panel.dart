import 'package:flutter/material.dart';
import 'package:flutter_auth_app/config/server_config.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'package:flutter_auth_app/services/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart'; // Importación necesaria para la navegación

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String selectedCategory = 'Operaciones de Usuario'; // Categoría seleccionada por defecto
  bool isMenuVisible = false; // Controla si el menú está visible en móvil

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; // Detectar si es móvil

    return BaseLayout(
      child: Stack(
        children: [
          // Mostrar contenido principal solo si el menú no está visible en móvil
          if (!isMobile || !isMenuVisible)
            Row(
              children: [
                if (!isMobile) _buildSidebar(), // Mostrar menú si no es móvil
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildContent(), // Contenido dinámico según la categoría seleccionada
                  ),
                ),
              ],
            ),
          // Mostrar menú lateral en móvil si está visible
          if (isMobile && isMenuVisible)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 200,
                height: MediaQuery.of(context).size.height,
                color: Colors.grey[900],
                child: _buildSidebar(),
              ),
            ),
          // Botón para alternar el menú en móvil
          if (isMobile)
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                icon: Icon(
                  isMenuVisible ? Icons.arrow_back : Icons.arrow_forward, // Cambiar ícono según el estado
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    isMenuVisible = !isMenuVisible; // Alternar visibilidad del menú
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final categories = [
      'Operaciones de Usuario',
      'Operaciones de Productos',
      'Operaciones de Pedidos',
      'Volver a Mi Cuenta', // Nueva categoría
    ];

    return Container(
      width: 200,
      color: Colors.grey[900],
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return ListTile(
            title: Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              setState(() {
                selectedCategory = category;
                if (MediaQuery.of(context).size.width < 600) {
                  isMenuVisible = false; // Ocultar el menú en móvil al seleccionar una categoría
                }

                // Navegar a "Mi Cuenta" si se selecciona la nueva categoría
                if (category == 'Volver a Mi Cuenta') {
                  context.go('/my-account'); // Redirigir a la página de "Mi Cuenta"
                }
              });
            },
            selected: isSelected,
            selectedTileColor: Colors.grey[800],
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedCategory) {
      case 'Operaciones de Usuario':
        return _buildUserOperations();
      case 'Operaciones de Productos':
        return _buildProductOperations();
      case 'Operaciones de Pedidos':
        return _buildOrderOperations();
      case 'Volver a Mi Cuenta':
        // Redirigir a "Mi Cuenta" (opcional, ya se maneja en el onTap del menú)
        Future.microtask(() => context.go('/my-account'));
        return const Center(
          child: CircularProgressIndicator(), // Mostrar un indicador mientras se redirige
        );
      default:
        return const Center(
          child: Text(
            'Selecciona una categoría',
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }

  Widget _buildUserOperations() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchData('users'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error al cargar usuarios', style: TextStyle(color: Colors.red)),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No hay usuarios disponibles', style: TextStyle(color: Colors.white70)),
          );
        }

        final users = snapshot.data!;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user['username'], style: const TextStyle(color: Colors.white)),
              subtitle: Text(user['email'], style: const TextStyle(color: Colors.white70)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteData('users', user['id']),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductOperations() {
    return Stack(
      children: [
        FutureBuilder<List<dynamic>>(
          future: _fetchData('games'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.blue));
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Error al cargar productos', style: TextStyle(color: Colors.red)),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No hay productos disponibles', style: TextStyle(color: Colors.white70)),
              );
            }

            final products = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Número de columnas
                crossAxisSpacing: 16.0, // Espaciado horizontal
                mainAxisSpacing: 16.0, // Espaciado vertical
                childAspectRatio: 4 / 1, // Relación de aspecto ajustada para tarjetas más estrechas
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800], // Fondo oscuro para la tarjeta
                    borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis, // Cortar texto si es muy largo
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _deleteData('games', product['id']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.red, // Fondo rojo para el botón
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: GestureDetector(
            onTap: () => _showAddGameDialog(),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue, // Fondo azul para el botón flotante
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderOperations() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchData('orders'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error al cargar pedidos', style: TextStyle(color: Colors.red)),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No hay pedidos disponibles', style: TextStyle(color: Colors.white70)),
          );
        }

        final orders = snapshot.data!;
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return ListTile(
              title: Text('Pedido ID: ${order['orderId']}', style: const TextStyle(color: Colors.white)),
              subtitle: Text('Total: \$${order['precio']}', style: const TextStyle(color: Colors.white70)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteData('orders', order['orderId']),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _fetchData(String endpoint) async {
    final token = Provider.of<AuthProvider>(context, listen: false).jwtToken;

    try {
      final response = await http.get(
        Uri.parse('${ServerConfig.serverIp}/gateway/$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener datos de $endpoint');
      }
    } catch (e) {
      print('Error fetching data from $endpoint: $e');
      throw Exception('Error al obtener datos de $endpoint');
    }
  }

  Future<void> _deleteData(String endpoint, String id) async {
    final token = Provider.of<AuthProvider>(context, listen: false).jwtToken;

    try {
      // Primera solicitud DELETE
      final response = await http.delete(
        Uri.parse('${ServerConfig.serverIp}/gateway/$endpoint/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 204) {
        // Si el endpoint es "users", realiza la segunda solicitud DELETE
        if (endpoint == 'users') {
          final authResponse = await http.delete(
            Uri.parse('${ServerConfig.serverIp}/gateway/auth/$id'),
            headers: {'Authorization': 'Bearer $token'},
          );

          if (authResponse.statusCode != 204) {
            print('Error deleting user in auth: ${authResponse.statusCode}');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al eliminar el usuario en auth'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        // Mostrar mensaje de éxito
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario eliminado con éxito'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el usuario'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión al servidor'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _addGame(
    String name,
    double precio,
    int? metacritic,
    String consola,
    String imageUrl,
    String descripcion,
  ) async {
    final token = Provider.of<AuthProvider>(context, listen: false).jwtToken;

    final newGame = {
      'name': name,
      'precio': precio,
      'metacritic': metacritic,
      'consola': consola,
      'imagen': imageUrl,
      'descripcion': descripcion,
    };

    try {
      final response = await http.post(
        Uri.parse('${ServerConfig.serverIp}/gateway/games'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(newGame),
      );

      if (response.statusCode == 201) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Juego agregado con éxito'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al agregar el juego'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Error adding game: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión al servidor'), backgroundColor: Colors.red),
      );
    }
  }

  void _showAddGameDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController precioController = TextEditingController();
    final TextEditingController metacriticController = TextEditingController();
    final TextEditingController consolaController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    final TextEditingController descripcionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[850], // Fondo oscuro
          child: SingleChildScrollView( // Hacer el contenido desplazable
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Agregar Nuevo Juego',
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildCustomTextField(nameController, 'Nombre'),
                  _buildCustomTextField(precioController, 'Precio', isNumeric: true),
                  _buildCustomTextField(metacriticController, 'Metacritic (opcional)', isNumeric: true),
                  _buildCustomTextField(consolaController, 'Consola'),
                  _buildCustomTextField(imageUrlController, 'URL de la Imagen'),
                  _buildCustomTextField(descripcionController, 'Descripción'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildCustomButton(
                        label: 'Cancelar',
                        color: Colors.red,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      _buildCustomButton(
                        label: 'Agregar',
                        color: Colors.green,
                        onPressed: () {
                          _addGame(
                            nameController.text,
                            double.tryParse(precioController.text) ?? 0.0,
                            int.tryParse(metacriticController.text),
                            consolaController.text,
                            imageUrlController.text,
                            descripcionController.text,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[800], // Fondo oscuro para el campo de texto
            borderRadius: BorderRadius.circular(4.0), // Bordes redondeados
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: const TextStyle(color: Colors.white), // Texto blanco
            decoration: const InputDecoration(
              border: InputBorder.none, // Sin bordes
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Espaciado interno
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCustomButton({required String label, required Color color, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color, // Color del botón
          borderRadius: BorderRadius.circular(4.0), // Bordes redondeados
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), // Texto blanco
        ),
      ),
    );
  }
}