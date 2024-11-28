FROM openjdk:17-jdk-slim

WORKDIR /app

COPY springbootadmin-0.0.1-SNAPSHOT.jar eureka-server.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "eureka-server.jar"]
