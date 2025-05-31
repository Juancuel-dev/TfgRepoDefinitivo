FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y curl git wget unzip xz-utils

# Install Flutter
RUN wget -q --tries=3 https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.5-stable.tar.xz -O flutter_sdk.tar.xz
RUN mkdir /opt/flutter
RUN ls -l flutter_sdk.tar.xz
RUN tar -xf flutter_sdk.tar.xz -C /opt/flutter --strip-components=1
ENV PATH="$PATH:/opt/flutter/bin"
ENV DART_SDK=/opt/dart-sdk
RUN flutter config --enable-web
RUN flutter doctor

# Install Dart
RUN apt-get update && apt-get install -y wget
RUN wget https://storage.googleapis.com/dart-archive/channels/stable/release/3.5.0/sdk/dartsdk-linux-x64-release.zip -O dartsdk.zip
RUN unzip dartsdk.zip -d /opt/
ENV PATH="$PATH:/opt/dart-sdk/bin"
RUN export PATH=$PATH:/opt/dart-sdk/bin
RUN dart --version

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Build the Flutter web app
RUN flutter build web

# Expose port 54695
EXPOSE 54695

# Start Dart HTTP server
CMD dart run :54695 --directory=build/web

HEALTHCHECK --interval=5s --timeout=3s \
  CMD curl -f http://localhost:54695/ || exit 1
