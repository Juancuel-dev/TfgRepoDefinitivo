FROM ubuntu:20.04

# Evita preguntas interactivas al instalar paquetes
ARG DEBIAN_FRONTEND=noninteractive

# Instala dependencias
RUN apt-get update && apt-get install -y \
  curl git wget unzip xz-utils libglu1-mesa \
  && apt-get clean

# Instala Flutter
RUN wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.5-stable.tar.xz -O flutter.tar.xz \
  && mkdir /opt/flutter \
  && tar -xf flutter.tar.xz -C /opt/flutter --strip-components=1

ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH"

# Prepara Flutter para compilación Web
RUN flutter doctor -v
RUN flutter config --enable-web
RUN flutter precache --web

# Crea y usa el directorio de la app
WORKDIR /app

# Copia los archivos de la app
COPY . .

# Obtiene dependencias
RUN flutter pub get

# Compila la app web
RUN flutter build web

# Instala servidor HTTP simple
RUN apt-get install -y nginx

# Copia archivos generados al directorio de NGINX
RUN rm -rf /var/www/html/* \
  && cp -r build/web/* /var/www/html/

# Expone el puerto que usa NGINX
EXPOSE 80

# Reemplaza el entrypoint para que NGINX sirva el sitio web
CMD ["nginx", "-g", "daemon off;"]

# Opcional: Healthcheck
HEALTHCHECK --interval=10s --timeout=5s CMD curl -f http://localhost/ || exit 1
