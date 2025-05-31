# Etapa de construcción - Usamos imagen oficial de Flutter desde Docker Hub
FROM flutter/flutter:stable AS build

# Configuración del entorno
WORKDIR /app
ENV FLUTTER_WEB_BUILD_MODE=release

# 1. Copia estratégica para optimizar caché
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# 2. Copia el código y construye
COPY . .
RUN flutter build web --release --web-renderer html --no-source-maps

# Etapa de producción - Usamos imagen oficial de Nginx
FROM nginx:stable-alpine

# Copia los archivos construidos
COPY --from=build /app/build/web /usr/share/nginx/html

# Configuración mínima de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Puerto expuesto (Railway lo manejará)
EXPOSE 54695

# Comando de inicio
CMD ["nginx", "-g", "daemon off;"]