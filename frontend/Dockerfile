FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y curl git wget unzip xz-utils

# Install Flutter
RUN wget -q --tries=3 https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.5-stable.tar.xz -O flutter_sdk.tar.xz
RUN mkdir /opt/flutter
RUN ls -l flutter_sdk.tar.xz
RUN tar -xf flutter_sdk.tar.xz -C /opt/flutter --strip-components=1
ENV PATH="$PATH:/opt/flutter/bin"
RUN flutter doctor

# Install Dart
RUN apt-get update && apt-get install -y apt-transport-https gnupg
RUN wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub -O dart.key
RUN gpg --dearmor dart.key | tee /etc/apt/trusted.gpg.d/dart.gpg > /dev/null && \
  retry_wget() { \
    wget --no-check-certificate -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian_stable/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list || \
    if [ $retries -gt 0 ]; then \
      echo "Download failed, retrying..." && retries=$((retries-1)) && sleep 1 && retry_wget; \
    else \
      echo "Download failed after multiple retries." && exit 1; \
    fi \
  }; \
  retries=3; retry_wget
RUN apt-get update && apt-get install -y dart

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Build the Flutter web app
RUN flutter build web

# Expose port 8080
EXPOSE 8080

# Start Dart HTTP server
CMD dart run :8080 --directory=build/web
