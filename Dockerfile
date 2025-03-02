# Build stage
FROM maven:3.8-openjdk-11 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Run stage
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/Smartspend.war /app/app.war
ENV PORT 8080
EXPOSE 8080
CMD ["java", "-Dserver.port=${PORT}", "-jar", "app.war"]