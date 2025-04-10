# Docker file for the Read Service
#
# Version 0.0.1

#jdk image
FROM openjdk:17-jdk-slim

# install

# label for the image
LABEL Description="Users Service" Version="0.0.1"

# the version of the archive
ARG VERSION=0.0.1

# mount the temp volume
VOLUME /tmp

# Add the service as app.jar
ADD target/microservice-users-0.0.1-SNAPSHOT.jar app.jar

# touch the archive for timestamp
RUN sh -c 'touch /app.jar'

# entrypoint to the image on run
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]