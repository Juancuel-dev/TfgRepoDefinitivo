FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y curl git wget unzip

# Install Flutter
RUN curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.5-stable.tar.xz -o flutter_sdk.tar.xz
RUN mkdir /opt/flutter
RUN tar -xf flutter_sdk.tar.xz -C /opt/flutter --strip-components=1
ENV PATH="$PATH:/opt/flutter/bin"
RUN flutter doctor

# Install Dart
RUN apt-get update && apt-get install -y apt-transport-https
RUN sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
RUN sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian_stable/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
RUN apt-get update && apt-get install -y dart

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Build the Flutter web app
RUN flutter build web

# Expose port 8080
EXPOSE 54695

# Start Dart HTTP server
CMD dart run :8080 --directory=build/web
