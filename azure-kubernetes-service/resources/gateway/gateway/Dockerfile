FROM mcr.microsoft.com/openjdk/jdk:17-mariner as build

WORKDIR /staging

# Install gradle
RUN tdnf install -y wget unzip

RUN wget https://services.gradle.org/distributions/gradle-8.8-bin.zip && \
    unzip -d /opt/gradle gradle-8.8-bin.zip && \
    chmod +x /opt/gradle/gradle-8.8/bin/gradle

ENV GRADLE_HOME=/opt/gradle/gradle-8.8
ENV PATH=$PATH:$GRADLE_HOME/bin

COPY . .

# Compile with gradle
RUN gradle build -x test

FROM mcr.microsoft.com/openjdk/jdk:17-mariner as runtime

WORKDIR /app

COPY --from=build /staging/build/libs/gateway-0.0.1-SNAPSHOT.jar .

ENTRYPOINT ["java", "-jar", "gateway-0.0.1-SNAPSHOT.jar"]