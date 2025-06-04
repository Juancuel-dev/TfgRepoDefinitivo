import 'package:flutter/material.dart';
import 'package:flutter_auth_app/config/server_config.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'package:flutter_auth_app/services/auth_provider.dart';
import 'package:flutter_auth_app/services/auth_service.dart';
import 'package:flutter_auth_app/services/image_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';


class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
int _reloadTrigger = 0;

  final Logger _logger = Logger(
    level: Level.debug,
    printer: PrettyPrinter(),
  );

  String selectedCategory = 'Operaciones de Usuario'; // Categoría seleccionada por defecto
  bool isMenuVisible = false; // Controla si el menú está visible en móvil
  List<OrderEntry> userOrders = []; // Lista de pedidos del usuario

  @override
  void initState() {
    super.initState();
    _fetchAllOrders(); // Obtener todos los pedidos al cargar la página
  }

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
      'Volver a Mi Cuenta',
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
        return _buildOrdersSection(); 
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
    key: ValueKey(_reloadTrigger), 
    future: _fetchData('users'),
    builder: (context, snapshot) {
      
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        );
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
      final authService = AuthService();

      return FutureBuilder<String?>(
        future: authService.getToken(),
        builder: (context, tokenSnapshot) {
          if (!tokenSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final token = tokenSnapshot.data!;
          final currentUsername = authService.getClaimFromToken(token, "username");

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final int? imageId = user['imagen'] is int
                  ? user['imagen']
                  : int.tryParse(user['imagen'].toString());

              final isSelf = user['username'] == currentUsername;

              return FutureBuilder<AssetImage>(
                future: imageId != null
                    ? ImageService.loadUserProfileImage(imageId, context)
                    : Future.value(const AssetImage('assets/images/default.jpg')),
                builder: (context, imageSnapshot) {
                  final AssetImage image = imageSnapshot.data ?? const AssetImage('assets/images/default.jpg');

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Colors.grey[850],
                    child: ListTile(
                      leading: CircleAvatar(backgroundImage: image),
                      title: Text(
                        user['nombre'] ?? 'Sin nombre',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Usuario: ${user['username']}', style: const TextStyle(color: Colors.white70)),
                          Text('Email: ${user['email']}', style: const TextStyle(color: Colors.white70)),
                          Text('Edad: ${user['edad']}', style: const TextStyle(color: Colors.white70)),
                          Text('País: ${user['pais']}', style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: isSelf ? Colors.grey : Colors.red),
                        onPressed: isSelf ? null : () => _deleteData('users', user['id']),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
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
          return LayoutBuilder(
            builder: (context, constraints) {
              // Determinar el número de columnas basado en el ancho de la pantalla
              final crossAxisCount = constraints.maxWidth > 1200 
                ? 4 
                : constraints.maxWidth > 800 
                  ? 3 
                  : constraints.maxWidth > 600 
                    ? 2 
                    : 1;

              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.75, 
                ),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
  final product = products[index];
  final productName = (product['name'] ?? 'sin-nombre').toString().replaceAll(' ', '-');

  return InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: () {
      context.go('/details/$productName');
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: DecorationImage(
                  image: NetworkImage(product['imagen'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product['name'] ?? 'Sin nombre',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 4),
                Text(
                  '${product['precio']?.toStringAsFixed(2) ?? 'N/A'}€',
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
                ),
                const Spacer(),
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${product['metacritic'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.amber, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.videogame_asset, color: Colors.blueAccent, size: 16),
                const SizedBox(width: 4),
                Text(
                  product['consola'] ?? 'N/A',
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  product['descripcion'] ?? 'Sin descripción',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () => _deleteData('games', product['id']),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
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
            ),
          ],
        ),
      ),
    ),
  );
},
              );
            },
          );
        },
      ),
      Positioned(
        bottom: 16,
        right: 16,
        child: FloatingActionButton(
          onPressed: () => _showAddGameDialog(),
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    ],
  );
}

  Widget _buildOrdersSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pedidos de Todos los Clientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          userOrders.isEmpty
              ? const Text(
                  'No hay pedidos realizados.',
                  style: TextStyle(color: Colors.white70),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userOrders.length,
                  itemBuilder: (context, index) {
                    final order = userOrders[index];
                    return Card(
                      color: Colors.grey[800],
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pedido ID: ${order.orderId}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cliente ID: ${order.clientId}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fecha: ${order.fecha.toLocal()}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Precio Total: ${order.precio.toStringAsFixed(2)}€',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Juegos:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            ...order.games.map((game) {
                              return Text(
                                '- ${game.name} (${game.consola}) - ${game.precio.toStringAsFixed(2)}€ (x${game.quantity})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
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
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error al obtener datos de $endpoint');
      }
    } catch (e) {
      print('Error fetching data from $endpoint: $e');
      throw Exception('Error al obtener datos de $endpoint');
    }
  }

  Future<void> _fetchAllOrders() async {
    final token = Provider.of<AuthProvider>(context, listen: false).jwtToken;

    _logger.i('Iniciando la solicitud para obtener todos los pedidos...');
    _logger.d('Token JWT: $token');

    try {
      final response = await http.get(
        Uri.parse('${ServerConfig.serverIp}/gateway/orders'),
        headers: {
          'Authorization': 'Bearer $token', // Pasar el token como parámetro de autorización
        },
      );

      _logger.i('Respuesta del servidor: ${response.statusCode}');
      _logger.d('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body); // Decodificar como lista dinámica
        _logger.d('Datos decodificados: $data');

        setState(() {
          userOrders = data.map((json) {
            _logger.d('Procesando pedido: $json');
            return OrderEntry.fromJson(json as Map<String, dynamic>); // Mapear a objetos OrderEntry
          }).toList();
        });

        _logger.i('Pedidos procesados correctamente: $userOrders');
      } else {
        _logger.e('Error al obtener los pedidos. Código de estado: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al obtener los pedidos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _logger.e('Error al realizar la solicitud', e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión al servidor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteData(String endpoint, String id) async {
  final authService = AuthService();
  final token = await authService.getToken();

  if (token == null || token.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Token no encontrado. Inicia sesión nuevamente.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    print (token);
    final response = await http.delete(
      
      Uri.parse('${ServerConfig.serverIp}/gateway/$endpoint/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
  setState(() {
    _reloadTrigger++;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Usuario eliminado correctamente'),
      backgroundColor: Colors.green,
    ),
  );

  if (endpoint == 'users') {
    final authResponse = await http.delete(
      Uri.parse('${ServerConfig.serverIp}/gateway/auth/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (authResponse.statusCode != 204) {
      debugPrint('Error deleting user in auth: ${authResponse.statusCode}');

      // Mostrar advertencia leve, sin tratarlo como fallo total
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario eliminado, pero no completamente del sistema (código: ${authResponse.statusCode})'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
} else {
  debugPrint('Error al eliminar del endpoint $endpoint: ${response.statusCode}');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error al eliminar: ${response.statusCode}'),
      backgroundColor: Colors.red,
    ),
  );
}

  } catch (e) {
    debugPrint('Exception al eliminar: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error inesperado al eliminar'),
        backgroundColor: Colors.red,
      ),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), 
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

class OrderEntry {
  final String orderId;
  final String clientId;
  final DateTime fecha;
  final double precio;
  final List<GameEntry> games;

  OrderEntry({
    required this.orderId,
    required this.clientId,
    required this.fecha,
    required this.precio,
    required this.games,
  });

  factory OrderEntry.fromJson(Map<String, dynamic> json) {
    return OrderEntry(
      orderId: json['orderId'] ?? 'Sin ID',
      clientId: json['clientId'] ?? 'Sin cliente',
      fecha: DateTime.parse(json['fecha']),
      precio: (json['precio'] as num).toDouble(),
      games: (json['games'] as List<dynamic>)
          .map((gameJson) => GameEntry.fromJson(gameJson as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GameEntry {
  final String name;
  final double precio;
  final String consola;
  final int quantity;

  GameEntry({
    required this.name,
    required this.precio,
    required this.consola,
    required this.quantity,
  });

  factory GameEntry.fromJson(Map<String, dynamic> json) {
    final game = json['game'] as Map<String, dynamic>; // Acceder al objeto 'game'
    return GameEntry(
      name: game['name'] ?? 'Sin nombre', 
      precio: (game['precio'] as num?)?.toDouble() ?? 0.0, 
      consola: game['consola'] ?? 'Desconocida',
      quantity: json['quantity'] as int? ?? 0, 
    );
  }
}
