import 'package:flutter/material.dart';
import 'package:flutter_auth_app/services/auth_service.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'package:go_router/go_router.dart'; // Importar GoRouter para la navegación

class LoginPage extends StatefulWidget {
  final Function(String) onLogin;

  const LoginPage({super.key, required this.onLogin});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Campo de nombre de usuario
                FractionallySizedBox(
                  widthFactor: 0.5, // Ocupa el 50% del ancho de la pantalla
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de Usuario',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 118, 194, 30)),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 118, 194, 30)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese su nombre de usuario';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de contraseña
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 118, 194, 30)),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 118, 194, 30)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese su contraseña';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Botón de inicio de sesión
                _isLoading
                    ? const CircularProgressIndicator(color: Color.fromARGB(255, 118, 194, 30))
                    : FractionallySizedBox(
                        widthFactor: 0.5,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                                _errorMessage = null;
                              });

                              try {
                                // Llamar al servicio de inicio de sesión
                                String? token = await _authService.login(
                                  _usernameController.text.trim(),
                                  _passwordController.text.trim(),
                                );

                                if (token == null) {
                                  // Mostrar un SnackBar si el token es nulo (error en el login)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Error: Usuario o contraseña incorrectos.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } else {
                                  // Si el login es exitoso, continuar con la navegación
                                  widget.onLogin(token);
                                  context.go('/'); // Navegación con GoRouter
                                }
                              } catch (e) {
                                // Manejar errores inesperados
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 98, 150, 38),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                // Mensaje de error
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16),

                // Enlace para crear cuenta
                MouseRegion(
                  cursor: SystemMouseCursors.click, // Cambiar el cursor a una mano señalando
                  child: GestureDetector(
                    onTap: () {
                      context.go('/register'); // Navegar a la pantalla de registro
                    },
                    child: const Text(
                      '¿No tienes cuenta? Crear Cuenta',
                      style: TextStyle(
                        color: Color.fromARGB(255, 118, 194, 30), // Color verde para resaltar
                        fontSize: 14, // Tamaño de fuente pequeño pero legible
                        fontWeight: FontWeight.w500, // Peso medio para destacar
                        decoration: TextDecoration.underline, // Subrayado para indicar que es un enlace
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}