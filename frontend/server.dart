import 'dart:io';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

void main() async {
  final handler = createStaticHandler('build/web', defaultDocument: 'index.html');
  final port = int.parse(Platform.environment['PORT'] ?? '56000');
  final server = await io.serve(handler, '0.0.0.0', port);
  print('✅ Servidor iniciado en http://localhost:${server.port}');
}
