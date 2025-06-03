import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

Middleware mimeFixer() {
  return (Handler innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);

      // Si la ruta termina con .js, aseguramos el content-type correcto
      if (request.url.path.endsWith('.js')) {
        // Solo si no está definido o está mal, lo corregimos
        final contentType = response.headers[HttpHeaders.contentTypeHeader];
        if (contentType == null || contentType == 'text/plain') {
          return response.change(headers: {
            HttpHeaders.contentTypeHeader: 'application/javascript',
          });
        }
      }

      return response;
    };
  };
}

void main() async {
  final staticHandler = createStaticHandler('build/web', defaultDocument: 'index.html');
  final handler = const Pipeline()
      .addMiddleware(mimeFixer())
      .addHandler(staticHandler);

  final port = int.parse(Platform.environment['PORT'] ?? '56000');
  final server = await io.serve(handler, '0.0.0.0', port);
  print('✅ Servidor iniciado en http://localhost:${server.port}');
}
