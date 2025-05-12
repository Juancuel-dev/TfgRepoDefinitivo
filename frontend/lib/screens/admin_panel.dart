import 'package:flutter/material.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String selectedCategory = 'Operaciones de Usuario'; // Categoría seleccionada por defecto
  bool isMenuVisible = false; // Controla si el menú está visible en móvil

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; // Detectar si es móvil

    return BaseLayout(
      child: Stack(
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
    final categories = [
      'Operaciones de Usuario',
      'Operaciones de Productos',
      'Operaciones de Pedidos',
    ];

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
      case 'Operaciones de Usuario':
        return _buildUserOperations();
      case 'Operaciones de Productos':
        return _buildProductOperations();
      case 'Operaciones de Pedidos':
        return _buildOrderOperations();
      default:
        return const Center(
          child: Text(
            'Selecciona una categoría',
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }

  Widget _buildUserOperations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Operaciones de Usuario',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Aquí puedes gestionar usuarios.',
          style: TextStyle(color: Colors.white70),
        ),
        // TODO: Agregar contenido específico para operaciones de usuario
      ],
    );
  }

  Widget _buildProductOperations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Operaciones de Productos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Aquí puedes gestionar productos.',
          style: TextStyle(color: Colors.white70),
        ),
        // TODO: Agregar contenido específico para operaciones de productos
      ],
    );
  }

  Widget _buildOrderOperations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Operaciones de Pedidos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Aquí puedes gestionar pedidos.',
          style: TextStyle(color: Colors.white70),
        ),
        // TODO: Agregar contenido específico para operaciones de pedidos
      ],
    );
  }
}