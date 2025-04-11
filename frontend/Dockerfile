FROM ghcr.io/cirruslabs/flutter:stable AS build

ENV FLUTTER_ALLOW_ROOT=true

WORKDIR /app
COPY . .

RUN flutter config --enable-web && \
    flutter build web --release --web-renderer html

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
