FROM ghcr.io/cirruslabs/flutter:3.13.9

WORKDIR /app

COPY . .

RUN flutter config --enable-web \
 && flutter pub get \
 && flutter build web

RUN dart pub get

EXPOSE 8080

CMD ["dart", "server.dart"]
