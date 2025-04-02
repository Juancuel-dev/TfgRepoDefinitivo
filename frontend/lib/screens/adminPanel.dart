import 'package:flutter/material.dart';
import 'package:flutter_auth_app/screens/baseLayout.dart';
import 'package:flutter_auth_app/models/cart.dart';

class AdminPanel extends StatefulWidget {
  final Cart cart;

  const AdminPanel({super.key, required this.cart});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final _gameNameController = TextEditingController();
  final _gamePriceController = TextEditingController();
  final List<String> users = ['user1', 'user2', 'user3']; // Lista de usuarios de ejemplo
  final List<Map<String, dynamic>> games = []; // Lista de juegos de ejemplo

  void _addGame() {
    final gameName = _gameNameController.text;
    final gamePrice = _gamePriceController.text;

    if (gameName.isNotEmpty && gamePrice.isNotEmpty) {
      setState(() {
        games.add({'name': gameName, 'price': double.tryParse(gamePrice) ?? 0.0});
      });
      _gameNameController.clear();
      _gamePriceController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Juego añadido con éxito')),
      );
    }
  }

  void _deleteGame(int index) {
    setState(() {
      games.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Juego eliminado con éxito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      cart: widget.cart,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel de Administración',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Sección para agregar un juego
              const Text(
                'Agregar Juego',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _gameNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Juego',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[800],
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _gamePriceController,
                decoration: InputDecoration(
                  labelText: 'Precio del Juego',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[800],
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Añadir Juego'),
              ),
              const SizedBox(height: 20),
              // Lista de juegos
              const Text(
                'Lista de Juegos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              games.isEmpty
                  ? const Text(
                      'No hay juegos añadidos.',
                      style: TextStyle(color: Colors.white70),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    game['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '\$${game['price'].toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () => _deleteGame(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 20),
              // Lista de usuarios
              const Text(
                'Lista de Usuarios',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      users[index],
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    _gamePriceController.dispose();
    super.dispose();
  }
}