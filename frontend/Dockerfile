# Etapa 1: Build de la app Flutter Web
FROM cirrusci/flutter:latest AS build
ENV FLUTTER_ALLOW_ROOT=true

WORKDIR /app
COPY . .

RUN flutter channel stable && \
    flutter upgrade && \
    flutter config --enable-web && \
    flutter build web --release --web-renderer html

# Etapa 2: Servir con Nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 54695
