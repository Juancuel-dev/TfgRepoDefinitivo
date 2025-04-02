import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserInfoPage extends StatefulWidget {
  final String token; // Token JWT del usuario

  const UserInfoPage({super.key, required this.token});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Map<String, dynamic>? userInfo;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/gateway/me'), // Cambia la URL según tu backend
        headers: {
          'Authorization': widget.token, // Pasar el token en el encabezado
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userInfo = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al conectar con el servidor: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información del Usuario'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del Usuario',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (userInfo != null) ...[
                        Text(
                          'ID: ${userInfo!['id']}',
                          style: const TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Nombre de Usuario: ${userInfo!['username']}',
                          style: const TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Rol: ${userInfo!['role']}',
                          style: const TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }
}