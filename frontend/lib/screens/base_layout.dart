import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_app/services/auth_provider.dart';

class BaseLayout extends StatefulWidget {
  final Widget child;
  final bool showBackButton;

  const BaseLayout({super.key, required this.child, this.showBackButton = true});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showCategories = false; // Controlar si el menú de categorías está visible
  bool _showSearchBar = false; // Controlar si la barra de búsqueda está visible
  final TextEditingController _searchController = TextEditingController();
  final Logger _logger = Logger(
    level: Level.debug, 
    printer: PrettyPrinter(), 
  );

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; // Detectar si es móvil

    _logger.i('Construyendo BaseLayout. ¿Es movil?: $isMobile'); // Log de información

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Column(
            children: [
              PreferredSize(
                preferredSize: const Size.fromHeight(80), // Altura personalizada del AppBar
                child: AppBar(
                  toolbarHeight: 80, // Ajustar la altura exacta del AppBar
                  automaticallyImplyLeading: widget.showBackButton,
                  backgroundColor: Colors.grey[900],
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuir elementos uniformemente
                    crossAxisAlignment: CrossAxisAlignment.center, // Centrar verticalmente
                    children: [
                      // Logo
                      Flexible(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click, // Cambiar el cursor al de una mano señalando
                          child: GestureDetector(
                            onTap: () {
                              _logger.i('Logo pulsado. Volviendo a home'); // Log de navegación
                              context.go('/'); // Navegación al inicio
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200), // Animación suave
                              height: 60, // Altura máxima del logo
                              constraints: const BoxConstraints(
                                maxWidth: 200, // Ancho máximo para evitar que ocupe demasiado espacio
                              ),
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('logo.png'), // Ruta al logo
                                  fit: BoxFit.contain, // Ajustar la imagen sin recortarla
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Categorías de plataformas
                      if (!isMobile)
                        Expanded(
                          flex: 2,
                          child: _buildPlatformCategories(context),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _showCategories = !_showCategories; // Alternar visibilidad del menú
                              _logger.i('Pulsado menu de categorias. _showCategories: $_showCategories'); // Log del estado
                            });
                          },
                        ),

                      // Acciones (como búsqueda, carrito, etc.)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _showSearchBar = !_showSearchBar; // Alternar visibilidad de la barra de búsqueda
                                _logger.i('Pulsado boton busqueda. _showSearchBar: $_showSearchBar'); // Log del estado
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.shopping_cart, color: Colors.white),
                            onPressed: () {
                              _logger.i('Navegando a carrito.'); // Log de navegación
                              context.go('/cart'); // Navegación al carrito
                            },
                          ),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return IconButton(
                                icon: const Icon(Icons.person, color: Colors.white), // Ícono de persona
                                onPressed: () {
                                  if (authProvider.isLoggedIn) {
                                    _logger.i('El usuario esta loggeado.'); // Log de usuario logueado
                                    context.go('/my-account'); // Navegar a My Account si está logueado
                                  } else {
                                    _logger.i('El usuario no esta loggeado'); // Log de usuario no logueado
                                    context.go('/login'); // Navegar al Login si no está logueado
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  centerTitle: false, // Desactivar centrado del título
                ),
              ),

              // Barra de búsqueda deslizante
              AnimatedContainer(
                duration: const Duration(milliseconds: 300), // Animación suave
                height: _showSearchBar ? 60 : 0, // Mostrar u ocultar la barra
                color: Colors.grey[900], // Mismo color que el header
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), // Agregar padding inferior
                child: _showSearchBar
                    ? Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar juegos...',
                                hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                                prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
                                filled: true,
                                fillColor: Colors.grey[850], // Fondo más oscuro para el campo
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8), // Bordes más pequeños
                                  borderSide: BorderSide.none, // Sin borde
                                ),
                              ),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  setState(() {
                                    _showSearchBar = false; // Ocultar la barra después de buscar
                                  });
                                  context.go('/search/$value'); // Navegar a la página de búsqueda
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                            onPressed: () {
                              setState(() {
                                _showSearchBar = false; // Ocultar la barra de búsqueda
                              });
                            },
                          ),
                        ],
                      )
                    : null,
              ),

              Expanded(child: widget.child),
            ],
          ),

          // Menú desplegable de categorías
          if (_showCategories)
            Positioned(
              top: 80, // Justo debajo del header
              left: 0,
              right: 0,
              child: _buildDropdownCategories(context),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          '© 2025 LevelUp Shop. Todos los derechos reservados.',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  // Método para construir las categorías de plataformas en pantallas grandes
  Widget _buildPlatformCategories(BuildContext context) {
    final platforms = [
      {'name': 'PS5', 'icon': Icons.sports_esports, 'color': Colors.white},
      {'name': 'PC', 'icon': Icons.computer, 'color': Colors.white},
      {'name': 'XBOX', 'icon': Icons.videogame_asset, 'color': Colors.white},
      {'name': 'SWITCH', 'icon': Icons.gamepad, 'color': Colors.white},
    ];

    return Wrap(
      spacing: 16.0, // Espacio horizontal entre elementos
      alignment: WrapAlignment.center, // Centrar los elementos horizontalmente
      children: platforms.map((platform) {
        return GestureDetector(
          onTap: () {
            context.go('/category/${platform['name']}'); // Navegar a la plataforma seleccionada
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 20, // Tamaño más pequeño del círculo
                backgroundColor: Colors.grey[800], // Fondo gris oscuro
                child: Icon(
                  platform['icon'] as IconData,
                  color: platform['color'] as Color, // Ícono en blanco
                  size: 20, // Tamaño más pequeño del ícono
                ),
              ),
              const SizedBox(height: 4),
              Text(
                platform['name'] as String,
                style: const TextStyle(
                  color: Colors.white, // Texto en blanco
                  fontSize: 12, // Tamaño de texto más pequeño
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Método para construir el menú desplegable de categorías en móviles
  Widget _buildDropdownCategories(BuildContext context) {
    final platforms = [
      {'name': 'PS5', 'icon': Icons.sports_esports},
      {'name': 'PC', 'icon': Icons.computer},
      {'name': 'XBOX', 'icon': Icons.videogame_asset},
      {'name': 'SWITCH', 'icon': Icons.gamepad},
    ];

    return Container(
      color: Colors.grey[900], // Mismo color que el header
      padding: const EdgeInsets.all(8.0), // Reducir el padding
      child: GridView.builder(
        shrinkWrap: true, // Ajustar el tamaño al contenido
        physics: const NeverScrollableScrollPhysics(), // Desactivar el scroll
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Número de columnas
          crossAxisSpacing: 8.0, // Espaciado horizontal reducido
          mainAxisSpacing: 8.0, // Espaciado vertical reducido
          childAspectRatio: 2.5, // Relación de aspecto ajustada para hacerlo más compacto
        ),
        itemCount: platforms.length,
        itemBuilder: (context, index) {
          final platform = platforms[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _showCategories = false; // Ocultar el menú
              });
              context.go('/category/${platform['name']}'); // Navegar a la plataforma seleccionada
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800], // Fondo gris oscuro
                borderRadius: BorderRadius.circular(6.0), // Bordes redondeados más pequeños
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(platform['icon'] as IconData, color: Colors.white, size: 24), // Ícono más pequeño
                  const SizedBox(height: 4), // Reducir el espacio entre ícono y texto
                  Text(
                    platform['name'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), // Texto más pequeño
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}