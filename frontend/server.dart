import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

Middleware mimeFixer() {
  return (Handler innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);

      if (request.url.path.endsWith('.js')) {
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

Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      print('📡 Petición: ${request.method} ${request.requestedUri}');
      final response = await innerHandler(request);
      print('➡️ Respuesta: ${response.statusCode} para ${request.requestedUri}');
      return response;
    };
  };
}

void main() async {
  final staticHandler = createStaticHandler('build/web', defaultDocument: 'index.html');

  final handler = Pipeline()
      .addMiddleware(loggingMiddleware())
      .addMiddleware(mimeFixer())
      .addHandler(staticHandler);

  final port = int.parse(Platform.environment['PORT'] ?? '56000');
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('✅ Servidor iniciado en http://localhost:${server.port}');
}
