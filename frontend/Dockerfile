# Etapa de construcción - Usamos imagen oficial de Flutter
FROM ghcr.io/flutter/flutter:stable AS build

# Configuración del entorno
WORKDIR /app
ENV FLUTTER_WEB_BUILD_MODE=release

# 1. Copia estratégica para optimizar caché
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# 2. Copia el código y construye
COPY . .
RUN flutter build web --release --web-renderer html --no-source-maps

# Etapa de producción - Usamos imagen Alpine con servidor web mínimo
FROM alpine:latest

# Instala un servidor HTTP mínimo (BusyBox)
RUN apk add --no-cache busybox

# Copia los archivos construidos
COPY --from=build /app/build/web /app

# Puerto expuesto (Railway lo manejará)
EXPOSE 8080

# Comando de inicio
CMD ["busybox", "httpd", "-f", "-p", "8080", "-h", "/app"]