import 'package:flutter/material.dart';
import 'package:flutter_auth_app/config/server_config.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'package:flutter_auth_app/services/auth_provider.dart';
import 'package:flutter_auth_app/services/auth_service.dart';
import 'package:flutter_auth_app/services/image_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String selectedCategory = 'Perfil'; // Categoría seleccionada por defecto
  bool isMenuVisible = false; // Controla si el menú está visible
  String? userRole; // Rol del usuario
  AssetImage? userProfileImage = const AssetImage('assets/images/default.jpg'); // Imagen de perfil seleccionada
  List<dynamic> userOrders = []; // Lista de pedidos del usuario

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Esto está bien en initState porque no depende del BuildContext
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _fetchUserOrders(String clientId, String jwtToken) async {
    try {
      final response = await http.get(
        Uri.parse('${ServerConfig.serverIp}/gateway/orders/user/$clientId'),
        headers: {
          'Authorization': 'Bearer $jwtToken', // Pasar el token como parámetro de autorización
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userOrders = data; // Guardar los pedidos obtenidos
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al obtener los pedidos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión al servidor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authService = AuthService();
    final token = authProvider.jwtToken;


    if (token == null) {
      Future.microtask(() => context.go('/login'));
      return;
    }

    // 1. Extraer clientId y rol del token JWT
    final clientId = authService.getClaimFromToken(token, 'clientId');
    final role = authService.getRoleFromToken(token);

    setState(() {
      userRole = role;
    });

    try {
      // 2. Llamar al método fetchUserInfo del AuthService
      final fetchedUserData = await authService.fetchUserInfo(token);

      if (fetchedUserData != null) {
        setState(() {
          print(fetchedUserData);
          userData = fetchedUserData;
          isLoading = false;
        });

        // 3. Usar el clientId para obtener los pedidos del usuario
        if (clientId != null) {
          await _fetchUserOrders(clientId, token);
        }
      } else {
        Future.microtask(() => context.go('/login'));
      }
    } catch (e) {
      print('Error fetching user data: $e');
      Future.microtask(() => context.go('/login'));
    }
    _loadUserProfileImage();
  }

  Future<void> _loadUserProfileImage() async {
    final imageId = userData?['imagen']; // Usar un ID por defecto si no está definido
    print('El image id es $imageId'); // Depuración
    try {
      final String imagePath = 'assets/images/$imageId.jpg'; // Ruta de la imagen en los assets
      setState(() {
        userProfileImage = AssetImage(imagePath); // Asignar el objeto AssetImage
      });
    } catch (e) {
      print('Error al cargar la imagen de perfil: $e');
    }
  }

  String? _getFavoriteConsole() {
    if (userOrders.isEmpty) return null;

    // Crear un mapa para contar los juegos por consola
    final Map<String, int> consoleCount = {};

    for (final order in userOrders) {
      final games = order['games'] as List<dynamic>;
      for (final game in games) {
        final console = game['game']['consola'] ?? 'Desconocida';
        consoleCount[console] = (consoleCount[console] ?? 0) + 1;
      }
    }

    // Encontrar la consola con el mayor número de juegos
    String? favoriteConsole;
    int maxCount = 0;

    consoleCount.forEach((console, count) {
      if (count > maxCount) {
        favoriteConsole = console;
        maxCount = count;
      }
    });

    return favoriteConsole;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; // Detectar si es móvil

    return BaseLayout(
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : Stack(
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
    // Categorías base
    final categories = ['Perfil', 'Mis Pedidos', 'Cambiar Contraseña', 'Cerrar Sesión'];

    // Verificar si el usuario es ADMIN y agregar la categoría "Admin Panel"
    if (userRole == 'ADMIN') {
      categories.insert(3, 'Admin Panel'); // Insertar "Admin Panel" antes de "Cerrar Sesión"
    }

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

                // Navegar al panel de administración si se selecciona "Admin Panel"
                if (category == 'Admin Panel') {
                  context.go('/admin'); // Redirigir a la ruta del panel de administración
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
      case 'Perfil':
        // Actualizar la consola favorita al abrir la sección "Perfil"
        final favoriteConsole = _getFavoriteConsole();
        return _buildProfileSection(favoriteConsole);
      case 'Mis Pedidos':
        return _buildOrdersSection();
      case 'Cambiar Contraseña':
        return _buildChangePasswordSection();
      case 'Cerrar Sesión':
        return _buildLogoutButton(context);
      case 'Admin Panel':
        Future.microtask(() => context.go('/admin')); // Redirigir a /admin
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

  Widget _buildProfileSection(String? favoriteConsole) {

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Mi Perfil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Información del usuario
          Card(
            color: Colors.grey[850],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showImagePickerDialog, // Cambiar imagen de perfil
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: userProfileImage ?? const AssetImage('assets/images/default.jpg'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData?['nombre'] ?? 'Nombre no disponible',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userData?['email'] ?? 'Email no disponible',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Usuario: ${userData?['username'] ?? 'No disponible'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Consola favorita
          if (favoriteConsole != null)
            MouseRegion(
              cursor: SystemMouseCursors.click, // Cambiar el puntero al de la mano
              child: GestureDetector(
                onTap: () {
                  // Navegar a la categoría de juegos de la consola favorita
                  context.go('/category/$favoriteConsole');
                },
                child: Card(
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.videogame_asset, color: Colors.blue),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Tu consola favorita es: $favoriteConsole',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          
        ],
      ),
    );
  }

  void _showImagePickerDialog() async {

    // Cargar las imágenes
    final images = await ImageService.loadAllProfileImages();

    // Mostrar el diálogo con las imágenes cargadas
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 300, // Ancho del diálogo
            height: 450, // Altura del diálogo
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Selecciona una nueva imagen de perfil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(), // Permitir scroll con efecto rebote
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Mostrar 3 imágenes por fila
                        crossAxisSpacing: 8.0, // Espaciado horizontal entre imágenes
                        mainAxisSpacing: 8.0, // Espaciado vertical entre imágenes
                        childAspectRatio: 1, // Relación de aspecto cuadrada para las imágenes
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final AssetImage image = images[index];
                        return GestureDetector(
                          onTap: () async {
                            print('Imagen seleccionada: ${image.assetName}');

                            // Realizar la petición para actualizar la imagen en el backend
                            await _updateUserProfileImage(image.assetName);

                            // Cerrar el diálogo después de completar la petición
                            Navigator.pop(context);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image(
                              image: image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateUserProfileImage(String newImagePath) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.jwtToken; // Obtener el token del usuario logueado

    if (token == null) {
      // Si no hay token, redirigir al login
      Future.microtask(() => context.go('/login'));
      return;
    }

    try {
      // Extraer el ID de la imagen del nombre del archivo
      final int imageId = _extractImageIdFromPath(newImagePath);

      // Crear el objeto UserDTO con los datos actuales del usuario
      final userDTO = {
        'nombre': userData?['nombre'] ?? 'Nombre no disponible',
        'username': userData?['username'] ?? 'Username no disponible',
        'email': userData?['email'] ?? 'Email no disponible',
        'image': imageId, // Nuevo ID de la imagen
      };

      // Enviar la solicitud PUT al backend
      final response = await http.put(
        Uri.parse('${ServerConfig.serverIp}/gateway/users/update-image/$imageId'), // Endpoint para actualizar el usuario
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Token de autenticación
        },
        body: jsonEncode(userDTO), // Convertir el objeto a JSON
      );

      if (response.statusCode == 200) {
        // Si la actualización es exitosa, actualizar la imagen localmente
        setState(() {
          userProfileImage = AssetImage(newImagePath); // Actualizar la imagen en la interfaz
          userData?['imageId'] = imageId; // Actualizar el ID de la imagen localmente
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen de perfil actualizada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Manejar errores del servidor
        print('Error al actualizar la imagen de perfil: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar la imagen de perfil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Manejar errores de red
      print('Error de conexión al servidor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión al servidor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _extractImageIdFromPath(String imagePath) {
    // Extraer el ID de la imagen del nombre del archivo
    final fileName = imagePath.split('/').last; // Obtener el nombre del archivo
    final imageId = int.tryParse(fileName.split('.').first); // Extraer el número antes de ".jpg"
    return imageId ?? 1; // Retornar 1 como valor por defecto si no se puede parsear
  }

  Widget _buildOrdersSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis Pedidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          userOrders.isEmpty
              ? const Text(
                  'No tienes pedidos realizados.',
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
                              'Pedido ID: ${order['orderId']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fecha: ${order['fecha']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Precio Total: \$${order['precio'].toStringAsFixed(2)}',
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
                            ...List<Widget>.from(order['games'].map((game) {
                              return Text(
                                '- ${game['game']['name']} (Cantidad: ${game['quantity']})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              );
                            })),
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

  Widget _buildChangePasswordSection() {
    final TextEditingController newPasswordController = TextEditingController();

    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cambiar Contraseña',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nueva Contraseña',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final newPassword = newPasswordController.text.trim();
                if (newPassword.isNotEmpty) {
                  _changePassword(newPassword);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, ingresa una nueva contraseña'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Cambiar Contraseña'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword(String newPassword) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.jwtToken;

    if (token == null) {
      print('JWT Token no encontrado. Redirigiendo al login.');
      Future.microtask(() => context.go('/login'));
      return;
    }

    print('Intentando cambiar contraseña...');
    print('Nueva contraseña: $newPassword');
    print('JWT Token: $token');

    try {
      final response = await http.post(
        Uri.parse('${ServerConfig.serverIp}/gateway/auth/change-password/$newPassword'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Contraseña cambiada con éxito.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña cambiada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('Error al cambiar la contraseña. Código de estado: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cambiar la contraseña'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error de conexión al servidor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión al servidor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          authProvider.logout(); // Llamar al método de logout
          context.go('/login'); // Navegar al login
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
        child: const Text('Cerrar Sesión'),
      ),
    );
  }
}