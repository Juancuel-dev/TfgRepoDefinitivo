import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

void main() async {
  final handler = Pipeline()
      .addMiddleware(fixContentType) // Middleware para corregir el Content-Type
      .addHandler(createStaticHandler('build/web', defaultDocument: 'index.html'));

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, '0.0.0.0', port);
  print('✅ Servidor iniciado en http://localhost:${server.port}');
}

// Middleware para corregir el Content-Type de archivos .js y .css
Middleware fixContentType = (Handler innerHandler) {
  return (Request request) async {
    final response = await innerHandler(request);
    final String? contentType;

    if (request.url.path.endsWith('.js')) {
      contentType = 'application/javascript';
    } else if (request.url.path.endsWith('.css')) {
      contentType = 'text/css';
    } else {
      return response; // No modificar otros tipos
    }

    return response.change(headers: {'Content-Type': contentType});
  };
};