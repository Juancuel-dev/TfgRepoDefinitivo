import 'package:flutter/material.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'package:flutter_auth_app/services/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
          Row(
            children: [
              if (!isMobile || isMenuVisible) _buildSidebar(), // Mostrar menú si es grande o está visible
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildContent(), // Contenido dinámico según la categoría seleccionada
                ),
              ),
            ],
          ),
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
    return FutureBuilder<List<dynamic>>(
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
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product['name'], style: const TextStyle(color: Colors.white)),
              subtitle: Text('Precio: \$${product['precio']}', style: const TextStyle(color: Colors.white70)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteData('games', product['id']),
              ),
            );
          },
        );
      },
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
        Uri.parse('http://localhost:8080/gateway/$endpoint'),
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
      final response = await http.delete(
        Uri.parse('http://localhost:8080/gateway/$endpoint/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Elemento eliminado con éxito'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar elemento'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar elemento'), backgroundColor: Colors.red),
      );
    }
  }
}