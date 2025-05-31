FROM ghcr.io/cirruslabs/flutter:3.10.5

WORKDIR /app

COPY . .

RUN flutter config --enable-web \
 && flutter pub get \
 && flutter build web

# Agrega el paquete shelf_static para servir archivos
RUN dart pub add shelf shelf_static

# Servidor Dart simple que sirve build/web
RUN echo 'import "dart:io";\n'\
'import "package:shelf/shelf.dart";\n'\
'import "package:shelf/shelf_io.dart" as io;\n'\
'import "package:shelf_static/shelf_static.dart";\n\n'\
'void main() async {\n'\
'  final handler = createStaticHandler("build/web", defaultDocument: "index.html");\n'\
'  final port = int.parse(Platform.environment["PORT"] ?? "8080");\n'\
'  final server = await io.serve(handler, "0.0.0.0", port);\n'\
'  print("✅ Servidor iniciado en http://localhost:\${server.port}");\n'\
'}' > server.dart

EXPOSE 8080

CMD ["dart", "server.dart"]
