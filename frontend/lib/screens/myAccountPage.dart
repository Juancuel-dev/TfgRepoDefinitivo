import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/userDTO.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';
import 'package:flutter_auth_app/services/authProvider.dart';
import 'package:flutter_auth_app/services/authService.dart';
import 'package:flutter_auth_app/services/imageService.dart';
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
  String? userProfileImage; // Imagen de perfil seleccionada

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadUserProfileImage();
  }

  Future<void> _fetchUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authService = AuthService();
    final token = authProvider.jwtToken; // Obtener el token del usuario logueado

    if (token == null) {
      // Si no hay token, redirigir al login
      Future.microtask(() => context.go('/login'));
      return;
    }

    // Extraer el rol del token
    final role = authService.getRoleFromToken(token);
    setState(() {
      userRole = role; // Guardar el rol del usuario
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/gateway/users/me'),
        headers: {
          'Authorization': 'Bearer $token', // Pasar el token como parámetro de autorización
        },
      );

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, parsear los datos del usuario
        final data = json.decode(response.body);
        setState(() {
          userData = data;
          isLoading = false;
        });
      } else {
        // Si el token no es válido o hay un error, redirigir al login
        Future.microtask(() => context.go('/login'));
      }
    } catch (e) {
      // Manejar errores de red o de la API
      Future.microtask(() => context.go('/login'));
    }
  }

  Future<void> _loadUserProfileImage() async {
    // Cargar la imagen de perfil del usuario actual
    final imageId = userData?['imageId'] ?? 1; // Usar un ID por defecto si no está definido
    final imagePath = await ImageService.loadUserProfileImage(imageId);
    setState(() {
      userProfileImage = imagePath;
    });
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
        return _buildProfileSection();
      case 'Mis Pedidos':
        return _buildOrdersSection();
      case 'Cambiar Contraseña':
        return _buildChangePasswordSection();
      case 'Cerrar Sesión':
        return _buildLogoutButton(context);
      default:
        return const Center(
          child: Text(
            'Selecciona una categoría',
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20), // Espacio adicional para separar el texto de la flecha
        const Text(
          'Mi Perfil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.grey[850],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerDialog, // Abrir el popup al hacer clic
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: userProfileImage != null
                            ? AssetImage(userProfileImage!)
                            : const AssetImage('assets/profile_pictures/default.png'),
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
                            overflow: TextOverflow.ellipsis, // Evitar desbordamientos
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userData?['email'] ?? 'Email no disponible',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis, // Evitar desbordamientos
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 32),
                Wrap(
                  spacing: 16, // Espaciado entre elementos
                  runSpacing: 16, // Espaciado entre filas
                  children: [
                    _buildProfileInfoTile(
                      icon: Icons.person,
                      label: 'Usuario',
                      value: userData?['username'] ?? 'No disponible',
                    ),
                    _buildProfileInfoTile(
                      icon: Icons.email,
                      label: 'Email',
                      value: userData?['email'] ?? 'No disponible',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerDialog() async {
    final images = await ImageService.loadAllProfileImages(); // Cargar todas las imágenes disponibles

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Selecciona una nueva imagen de perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Cambiar dinámicamente según el tamaño de pantalla
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final imagePath = images[index];
                    return GestureDetector(
                      onTap: () {
                        _showConfirmationDialog(imagePath); // Mostrar el diálogo de confirmación
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(String selectedImagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Confirmar selección',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '¿Estás seguro de que deseas seleccionar esta imagen como tu nueva foto de perfil?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo de confirmación
                Navigator.of(context).pop(); // Cerrar el diálogo de selección de imagen
                _updateUserProfileImage(selectedImagePath); // Actualizar la imagen de perfil
              },
              child: const Text(
                'Sí',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
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
      // Crear el objeto UserDTO con los datos actuales del usuario
      final userDTO = UserDTO(
        nombre: userData?['nombre'] ?? 'Nombre no disponible',
        username: userData?['username'] ?? 'Username no disponible',
        email: userData?['email'] ?? 'Email no disponible',
        image: _extractImageIdFromPath(newImagePath), // Nuevo ID de la imagen
      );

      // Enviar la solicitud PUT al backend
      final response = await http.put(
        Uri.parse('http://localhost:8080/users/update'), // Endpoint para actualizar el usuario
        headers: {
          'Authorization': 'Bearer $token', // Pasar el token como parámetro de autorización
          'Content-Type': 'application/json',
        },
        body: json.encode(userDTO.toJson()), // Convertir el UserDTO a JSON
      );

      if (response.statusCode == 200) {
        // Si la actualización es exitosa, actualizar la imagen localmente
        setState(() {
          userProfileImage = newImagePath;
          userData?['image'] = _extractImageIdFromPath(newImagePath); // Actualizar el imageId localmente
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen de perfil actualizada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Manejar errores del servidor
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar la imagen de perfil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Manejar errores de red
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
    final imageId = int.tryParse(fileName.split('.').first); // Extraer el número antes de ".png"
    return imageId ?? 1; // Retornar 1 como valor por defecto si no se puede parsear
  }

  Widget _buildProfileInfoTile({required IconData icon, required String label, required String value}) {
    return SizedBox(
      width: 120, // Ancho fijo para evitar desbordamientos
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, // Evitar desbordamientos
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection() {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const Text(
              'No tienes pedidos realizados.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    final TextEditingController currentPasswordController =
        TextEditingController();
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
              controller: currentPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Contraseña Actual',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
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
                final currentPassword = currentPasswordController.text.trim();
                final newPassword = newPasswordController.text.trim();
                if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {
                  // Lógica para cambiar la contraseña
                  _changePassword(currentPassword, newPassword);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, completa todos los campos'),
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

  Future<void> _changePassword(String currentPassword, String newPassword) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.jwtToken;

    if (token == null) {
      Future.microtask(() => context.go('/login'));
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080/users/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña cambiada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cambiar la contraseña'),
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