# Usa una imagen base de Java (por ejemplo, OpenJDK 17)
FROM openjdk:17-jdk-slim

# Define el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia el archivo JAR de tu aplicación al contenedor
COPY target/microservice_games.jar app.jar

# Expone el puerto que usará tu aplicación (por defecto Spring Boot usa 8080)
EXPOSE 8082

# Ejecuta el archivo JAR con Java cuando el contenedor se inicie
ENTRYPOINT ["java", "-jar", "app.jar"]