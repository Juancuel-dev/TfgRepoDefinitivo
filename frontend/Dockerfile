FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# Instala dependencias necesarias
RUN apt-get update && apt-get install -y \
  curl git wget unzip xz-utils libglu1-mesa ca-certificates nginx \
  && apt-get clean

# Instala Flutter
RUN wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.5-stable.tar.xz -O flutter.tar.xz \
  && mkdir /opt/flutter \
  && tar -xf flutter.tar.xz -C /opt/flutter --strip-components=1

ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH"

# Prepara Flutter para compilación Web
RUN flutter config --enable-web
RUN flutter precache --web

# Establece el directorio de trabajo
WORKDIR /app

# Copia archivos del proyecto
COPY . .

# Diagnóstico: Muestra estructura de archivos y contenido de pubspec.yaml
RUN echo "✅ Verificando archivos copiados:" && \
    ls -la /app && \
    echo "✅ Mostrando pubspec.yaml:" && \
    cat pubspec.yaml

# Corre doctor para detectar errores del proyecto
RUN flutter doctor -v

# Obtiene las dependencias del proyecto
RUN flutter pub get

# Compila la aplicación Flutter Web
RUN flutter build web

# Copia los archivos web a NGINX
RUN rm -rf /var/www/html/* \
  && cp -r build/web/* /var/www/html/

# Expone el puerto web
EXPOSE 80

# Sirve la app con NGINX
CMD ["nginx", "-g", "daemon off;"]

# Healthcheck para Railway
HEALTHCHECK --interval=10s --timeout=5s CMD curl -f http://localhost/ || exit 1
