# =========================
# Stage 1: Build
# =========================
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml first for dependency caching
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests


# =========================
# Stage 2: Runtime
# =========================
FROM eclipse-temurin:17-jre-jammy

# Create non-root user
RUN useradd -m springuser

WORKDIR /app

# Copy jar from builder stage
COPY --from=builder /app/target/devops-ci-cd-0.0.1-SNAPSHOT.jar app.jar

# Change ownership
RUN chown springuser:springuser app.jar

USER springuser

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]
