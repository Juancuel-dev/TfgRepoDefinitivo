import 'package:flutter/material.dart';
import 'package:flutter_auth_app/models/userDTO.dart'; // Asegúrate de que la ruta sea correcta
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _responseMessage = '';

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      final url = Uri.parse('http://localhost:8080/login');

      // Crea un objeto UserDTO
      final userDTO = UserDTO(username: username, password: password);

      // Convierte el objeto a JSON
      final body = jsonEncode(userDTO.toJson());

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json', // Asegúrate de incluir este encabezado
          },
          body: body,
        );

        if (response.statusCode == 200) {
          setState(() {
            _responseMessage = 'Login exitoso: ${response.body}';
          });
        } else {
          setState(() {
            _responseMessage = 'Error: ${response.statusCode} - ${response.body}';
          });
        }
      } catch (e) {
        setState(() {
          _responseMessage = 'Error de conexión: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
      ),
      body: Padding(
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
                onPressed: _login,
                child: const Text('Iniciar Sesión'),
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