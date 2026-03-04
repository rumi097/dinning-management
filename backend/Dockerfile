# ---- Build stage ----
FROM eclipse-temurin:21-jdk-alpine AS build
RUN apk add --no-cache dos2unix
WORKDIR /app
COPY mvnw pom.xml ./
COPY .mvn .mvn
RUN dos2unix mvnw && chmod +x mvnw
# Download dependencies first (cached layer)
RUN ./mvnw dependency:go-offline -B
COPY src src
RUN ./mvnw package -DskipTests -B

# ---- Run stage ----
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=prod"]
