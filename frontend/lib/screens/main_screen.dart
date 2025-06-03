import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_auth_app/config/server_config.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'package:flutter_auth_app/models/game.dart';
import 'package:flutter_auth_app/services/games_service.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_auth_app/services/auth_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:logger/logger.dart'; // Importa el paquete logger

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final Logger _logger = Logger(); // Instancia del logger

  @override
  Widget build(BuildContext context) {
    _logger.i('Construyendo la pantalla principal'); // Log de inicio de construcción

    return Scaffold(
      body: Stack(
        children: [
          // Contenido principal
          BaseLayout(
            showBackButton: false,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeaturedGameSection(context),
                    const SizedBox(height: 32),
                    const Text(
                      'Productos Populares',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPopularProductsSection(context),
                    const SizedBox(height: 32),
                    const Text(
                      'Juegos en Oferta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDiscountedGamesSection(context),
                  ],
                ),
              ),
            ),
          ),

          // Botón flotante de IA
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              onPressed: () {
                _logger.i('Botón de IA pulsado'); // Log del botón de IA
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.grey[900],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) => _ChatWidget(),
                );
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir la sección de juego destacado
  Widget _buildFeaturedGameSection(BuildContext context) {
    _logger.i('Construyendo la sección de juego destacado'); // Log de inicio de sección

    return FutureBuilder<List<Game>>(
      future: GamesService().fetchDiscountedGames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          _logger.i('Cargando juegos destacados'); // Log de carga
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          _logger.e('Error al cargar juegos destacados: ${snapshot.error}'); // Log de error
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          _logger.w('No se encontraron juegos destacados'); // Log de advertencia
          return const Center(
            child: Text(
              'No se encontraron juegos en oferta.',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          final random = Random();
          final featuredGame = snapshot.data![random.nextInt(snapshot.data!.length)];
          final originalPrice = (featuredGame.precio / (1 - (15 + random.nextInt(36)) / 100)).toStringAsFixed(2);

          _logger.i('Juego destacado seleccionado: ${featuredGame.name}'); // Log del juego destacado

          return Stack(
            children: [
              // Imagen de fondo
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  featuredGame.imageUrl,
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    _logger.e('Error al cargar la imagen del juego destacado: $error'); // Log de error de imagen
                    return const Center(
                      child: Icon(Icons.error, color: Colors.red, size: 50),
                    );
                  },
                ),
              ),
              // Contenido superpuesto
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      featuredGame.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '$originalPrice€',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${featuredGame.precio.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        _logger.i('Navegando a los detalles del juego: ${featuredGame.name}'); // Log de navegación
                        final formattedName = featuredGame.name.replaceAll(' ', '-');
                        context.go('/details/$formattedName');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Ver Detalles',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  // Sección de productos populares
  Widget _buildPopularProductsSection(BuildContext context) {
    _logger.i('Construyendo la sección de productos populares'); // Log de inicio de sección

    return FutureBuilder<List<Game>>(
      future: GamesService().fetchGames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          _logger.i('Cargando productos populares'); // Log de carga
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          _logger.e('Error al cargar productos populares: ${snapshot.error}'); // Log de error
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          _logger.w('No se encontraron productos populares'); // Log de advertencia
          return const Center(
            child: Text(
              'No se encontraron juegos populares.',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          final games = snapshot.data!.take(9).toList(); // Limitar a 9 juegos
          final isMobile = MediaQuery.of(context).size.width < 600;

          if (isMobile) {
            // Diseño para dispositivos móviles: fila deslizable
            return SizedBox(
              height: 150, // Altura de las tarjetas
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return Container(
                    width: 120, // Ancho de cada tarjeta
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        _logger.i('Navegando a los detalles del juego: ${game.name}'); // Log de navegación
                        final formattedName = game.name.replaceAll(' ', '-'); // Reemplazar espacios por guiones
                        context.go(
                          '/details/$formattedName', // Pasar el nombre del juego formateado en la URL
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1.5,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                              child: Image.network(
                                game.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  _logger.e('Error al cargar la imagen del juego: $error'); // Log de error de imagen
                                  return const Center(
                                    child: Icon(Icons.error, color: Colors.red, size: 50),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  game.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${game.precio.toStringAsFixed(2)}€',
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            // Diseño para pantallas grandes: grid 3x3 con mucho padding
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(64.0), // Mucho padding alrededor
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Desactivar scroll interno
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Tres columnas
                    crossAxisSpacing: 32.0, // Espaciado horizontal entre tarjetas
                    mainAxisSpacing: 32.0, // Espaciado vertical entre tarjetas
                    childAspectRatio: 0.75, // Proporción de las tarjetas
                  ),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                      ),
                      child: InkWell(
                        onTap: () {
                          _logger.i('Navegando a los detalles del juego: ${game.name}'); // Log de navegación
                          final formattedName = game.name.replaceAll(' ', '-'); // Reemplazar espacios por guiones
                          context.go(
                            '/details/$formattedName', // Pasar el nombre del juego formateado en la URL
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1.5,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                                child: Image.network(
                                  game.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    _logger.e('Error al cargar la imagen del juego: $error'); // Log de error de imagen
                                    return const Center(
                                      child: Icon(Icons.error, color: Colors.red, size: 50),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0), // Espaciado interno
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    game.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${game.precio.toStringAsFixed(2)}€',
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        }
      },
    );
  }

  // Método para construir la sección de juegos en oferta
  Widget _buildDiscountedGamesSection(BuildContext context) {
    _logger.i('Construyendo la sección de juegos en oferta'); // Log de inicio de sección

    return FutureBuilder<List<Game>>(
      future: GamesService().fetchDiscountedGames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          _logger.i('Cargando juegos en oferta'); // Log de carga
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          _logger.e('Error al cargar juegos en oferta: ${snapshot.error}'); // Log de error
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          _logger.w('No se encontraron juegos en oferta'); // Log de advertencia
          return const Center(
            child: Text(
              'No hay juegos en oferta.',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          final games = snapshot.data!;
          final ScrollController scrollController = ScrollController();

          _logger.i('Juegos en oferta cargados correctamente'); // Log de éxito

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 300, // Altura de las tarjetas
                child: Stack(
                  children: [
                    // Lista horizontal de juegos
                    ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        final originalPrice = (game.precio / (1 - (15 + Random().nextInt(36)) / 100)).toStringAsFixed(2);

                        return Container(
                          width: 200, // Ancho de cada tarjeta
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              _logger.i('Navegando a los detalles del juego: ${game.name}'); // Log de navegación
                              final formattedName = game.name.replaceAll(' ', '-'); // Reemplazar espacios por guiones
                              context.go(
                                '/details/$formattedName', // Pasar el nombre del juego formateado en la URL
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1.5,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                                    child: Image.network(
                                      game.imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        _logger.e('Error al cargar la imagen del juego: $error'); // Log de error de imagen
                                        return const Center(
                                          child: Icon(Icons.error, color: Colors.red, size: 50),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        game.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '$originalPrice€',
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${game.precio.toStringAsFixed(2)}€',
                                            style: const TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Flecha izquierda
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () {
                          scrollController.animateTo(
                            scrollController.offset - 220, // Desplazar hacia atrás
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),

                    // Flecha derecha
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onPressed: () {
                          scrollController.animateTo(
                            scrollController.offset + 220, // Desplazar hacia adelante
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

// Widget del chat
class _ChatWidget extends StatefulWidget {
  @override
  State<_ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<_ChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Ya no cargamos el historial del chat
  }

  // Método para procesar el texto del bot y convertir nombres de juegos en enlaces
  List<InlineSpan> _processBotMessage(String message) {
    // Expresión regular para capturar texto entre **, *, o ""
    final regex = RegExp(r'(\*\*.*?\*\*|\*.*?\*|".*?")');
    final spans = <InlineSpan>[];
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(message)) {
      // Agregar texto antes del enlace
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: message.substring(lastMatchEnd, match.start),
          style: const TextStyle(color: Colors.white),
        ));
      }

      // Capturar el texto entre los delimitadores
      final rawText = match.group(0)!;
      final gameName = rawText.replaceAll(RegExp(r'[\*\"]'), '').trim(); // Eliminar * y " del texto

      // Agregar el texto como enlace
      spans.add(TextSpan(
        text: gameName,
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // Navegar a /search/{nombre del juego}
            context.go('/search/$gameName');
          },
      ));

      lastMatchEnd = match.end;
    }

    // Agregar texto restante después del último enlace
    if (lastMatchEnd < message.length) {
      spans.add(TextSpan(
        text: message.substring(lastMatchEnd),
        style: const TextStyle(color: Colors.white),
      ));
    }

    return spans;
  }

  Future<void> _sendMessage(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jwtToken = authProvider.jwtToken; // Obtener el token JWT si está disponible
    final userMessage = _controller.text.trim();

    // Verificar si el mensaje está vacío
    if (userMessage.isEmpty) {
      print('El mensaje del usuario está vacío.');
      return;
    }

    print('Mensaje del usuario: $userMessage');
    if (jwtToken != null) {
      print('Token JWT: $jwtToken');
    } else {
      print('El usuario no está logueado. No se enviará el token JWT.');
    }

    setState(() {
      _messages.add({"role": "user", "message": userMessage});
      _controller.clear();
      _isLoading = true;
    });

    try {
      // Construir los encabezados de la solicitud
      final headers = {
        'Content-Type': 'application/json',
        if (jwtToken != null) 'Authorization': 'Bearer $jwtToken', // Agregar el token solo si está disponible
      };

      // Realizar la solicitud HTTP
      final response = await http.post(
        Uri.parse('${ServerConfig.serverIp}/gateway/ai'),
        headers: headers,
        body: jsonEncode({"texto": userMessage}),
      );

      print('Estado de la respuesta: ${response.statusCode}');
      print('Cuerpo de la respuesta (sin decodificar): ${response.body}');

      if (response.statusCode == 200) {
        // Decodificar correctamente el cuerpo de la respuesta como UTF-8
        final decodedBody = utf8.decode(response.bodyBytes);
        print('Cuerpo de la respuesta (decodificado): $decodedBody');

        final data = jsonDecode(decodedBody);
        final botMessage = data['content'][0]['text'];

        print('Mensaje del bot: $botMessage');

        setState(() {
          _messages.add({"role": "bot", "message": botMessage});
        });
      } else {
        print('Error en la respuesta del servidor: ${response.body}');
        setState(() {
          _messages.add({"role": "bot", "message": "Error: No se pudo procesar tu solicitud."});
        });
      }
    } catch (e) {
      print('Error al enviar la solicitud: $e');
      setState(() {
        _messages.add({"role": "bot", "message": "Error: $e"});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          const Text(
            'LevelUp AI',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Divider(color: Colors.white),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isUser
                        ? Text(
                            message['message']!,
                            style: const TextStyle(color: Colors.white),
                          )
                        : RichText(
                            text: TextSpan(
                              children: _processBotMessage(message['message']!),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () => _sendMessage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}