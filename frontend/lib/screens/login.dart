import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/cart.dart';
import 'package:flutter_auth_app/services/authService.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';

class LoginPage extends StatefulWidget {
  final Cart cart;
  final Function(String) onLogin;

  const LoginPage({super.key, required this.cart, required this.onLogin});

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
      cart: widget.cart,
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
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Campo de nombre de usuario
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de Usuario',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[800],
                        labelStyle: const TextStyle(color: Colors.white70),
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
                          return 'Por favor, ingrese su contraseña';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botón de inicio de sesión
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                  _errorMessage = null;
                                });
                                String? token = await _authService.login(
                                  _usernameController.text,
                                  _passwordController.text,
                                );
                                setState(() {
                                  _isLoading = false;
                                });
                                if (token != null) {
                                  widget.onLogin(token);
                                  Navigator.pushReplacementNamed(context, '/home', arguments: token);
                                } else {
                                  setState(() {
                                    _errorMessage = 'Error al iniciar sesión. Por favor, inténtelo de nuevo.';
                                  });
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            child: const Text('Iniciar Sesión'),
                          ),
                        ),
                  // Mensaje de error
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}