import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';
import 'package:flutter_auth_app/services/authProvider.dart';
import 'package:flutter_auth_app/services/authService.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('favicon.png'), // Imagen de perfil
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
                  // TODO: Implementar lógica para cambiar la contraseña
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