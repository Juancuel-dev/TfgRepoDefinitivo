import 'package:flutter/material.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';
import 'package:flutter_auth_app/services/authService.dart';
import 'package:flutter_auth_app/models/cart.dart';

class RegisterPage extends StatefulWidget {
  final Cart cart;
  final Function(String) onRegister;

  RegisterPage({required this.cart, required this.onRegister});

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
      cart: widget.cart,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu usuario';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Registrarse'),
              ),
              const SizedBox(height: 20),
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
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}