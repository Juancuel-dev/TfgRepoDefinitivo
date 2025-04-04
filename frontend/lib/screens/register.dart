import 'package:flutter/material.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';
import 'package:flutter_auth_app/services/authService.dart';

class RegisterPage extends StatefulWidget {
  final Function(String) onRegister;

  const RegisterPage({super.key, required this.onRegister});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _responseMessage = '';
  final AuthService _authService = AuthService();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      final success = await _authService.register(username, password);

      setState(() {
        if (success) {
          _responseMessage = 'Registro exitoso';
          String token = 'your-jwt-token'; // Simular obtención del token
          widget.onRegister(token);
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _responseMessage = 'Error: El usuario ya existe';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título
                  const Text(
                    'Registro',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Campo de usuario
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[800],
                        labelStyle: const TextStyle(color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa tu usuario';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Campo de contraseña
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[800],
                        labelStyle: const TextStyle(color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa tu contraseña';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botón de registro
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Registrarse'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Mensaje de respuesta
                  Text(
                    _responseMessage,
                    style: TextStyle(
                      color: _responseMessage.contains('Error') ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}