# Usamos la imagen oficial de Flutter para construir
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Configuramos el entorno de trabajo
WORKDIR /app

# 1. Copiamos primero solo las dependencias para optimizar la caché
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# 2. Copiamos el resto del código fuente
COPY . .

# 3. Construimos la aplicación web en modo release
RUN flutter build web --release --web-renderer html --no-source-maps

# Etapa de producción - usamos la imagen mínima de Dart
FROM google/dart:stable-sdk

# Instalamos dhttpd (servidor web liviano)
RUN pub global activate dhttpd

# Copiamos los archivos construidos
COPY --from=build /app/build/web /app/web

# Puerto que usará Railway (puede ser cualquier puerto, Railway lo manejará)
EXPOSE 8080

# Comando para iniciar el servidor web
CMD ["dhttpd", "--path", "/app/web", "--port", "8080"]