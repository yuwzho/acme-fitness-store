FROM mcr.microsoft.com/openjdk/jdk:17-ubuntu AS builder

WORKDIR /home/app
ADD . /home/app/spring-cloud-config
RUN cd spring-cloud-config && ./mvnw -Dmaven.test.skip=true clean package

# Stage 2: Final Stage
FROM mcr.microsoft.com/openjdk/jdk:17-mariner

WORKDIR /home/app
COPY --from=builder /home/app/spring-cloud-config/target/*.jar spring-cloud-config.jar
ENTRYPOINT ["java", "-jar", "spring-cloud-config.jar"]