import 'package:flutter/material.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'package:flutter_auth_app/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function(String token)? onRegister; // Callback opcional para manejar el token después del registro

  const RegisterPage({super.key, this.onRegister});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService(); // Instancia del servicio de autenticación
  bool _isLoading = false; // Controla el estado de carga

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
                  'Crea tu cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Nombre
                FractionallySizedBox(
                  widthFactor: 0.5, // Ocupa el 50% del ancho de la pantalla
                  child: _buildTextField(
                    controller: _nameController,
                    label: 'Nombre',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Email
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Por favor, ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Usuario
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: _buildTextField(
                    controller: _usernameController,
                    label: 'Usuario',
                    icon: Icons.account_circle,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu nombre de usuario';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Contraseña
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: _buildTextField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    icon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Botón de Registro
                _isLoading
                    ? const CircularProgressIndicator(color: Color.fromARGB(255, 118, 194, 30))
                    : FractionallySizedBox(
                        widthFactor: 0.5,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  Color.fromARGB(255, 98, 150, 38),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });

                              // Llamar al servicio de registro
                              final name = _nameController.text.trim();
                              final email = _emailController.text.trim();
                              final username = _usernameController.text.trim();
                              final password = _passwordController.text.trim();

                              final success = await _authService.register(
                                name,
                                username,
                                password,
                                email,
                              );

                              setState(() {
                                _isLoading = false;
                              });

                              if (success) {
                                // Simular un token de registro (puedes obtenerlo del backend si es necesario)
                                final fakeToken = 'fake_jwt_token';

                                // Llamar al callback onRegister si está definido
                                if (widget.onRegister != null) {
                                  widget.onRegister!(fakeToken);
                                }

                                // Mostrar mensaje de éxito
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Registro exitoso'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Redirigir al home o a otra pantalla
                                Navigator.of(context).pop();
                              } else {
                                // Mostrar mensaje de error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Error al registrar usuario'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Color.fromARGB(255, 118, 194, 30)),
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
      validator: validator,
    );
  }
}