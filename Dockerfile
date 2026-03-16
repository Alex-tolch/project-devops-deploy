FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build

FROM eclipse-temurin:21-jdk-alpine AS backend-builder

WORKDIR /app
COPY gradlew ./
COPY gradle gradle
COPY build.gradle.kts settings.gradle.kts versions.properties ./

COPY src src

RUN mkdir -p src/main/resources/static
COPY --from=frontend-builder /app/frontend/dist ./src/main/resources/static/

RUN chmod +x gradlew && ./gradlew build --no-daemon -x spotlessCheck

FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

RUN addgroup -g 1000 app && adduser -u 1000 -G app -s /bin/sh -D app

COPY --from=backend-builder /app/build/libs/project-devops-deploy-*.jar app.jar

RUN chown -R app:app /app

USER app

EXPOSE 8080
EXPOSE 9090

ENTRYPOINT ["java", "-jar", "app.jar"]
