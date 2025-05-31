# Etapa de construcción - Usamos imagen base de Ubuntu e instalamos Flutter manualmente
FROM ubuntu:22.04 AS build

# Instala dependencias básicas
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    xz-utils \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Instala Flutter manualmente
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="$PATH:/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin"

# Verifica la instalación
RUN flutter doctor -v

# Configura el entorno de trabajo
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release --web-renderer html --no-source-maps

# Etapa de producción - Servidor web mínimo
FROM busybox:latest

# Copia los archivos construidos
COPY --from=build /app/build/web /app

# Expone el puerto 8080 (Railway lo manejará)
EXPOSE 8080

# Inicia un servidor HTTP simple
CMD ["busybox", "httpd", "-f", "-p", "8080", "-h", "/app"]