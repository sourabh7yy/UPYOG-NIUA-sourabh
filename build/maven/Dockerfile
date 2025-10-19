# ---------- Build Stage ----------
# Use a public Maven + JDK 17 image for building
FROM maven:3.9.9-eclipse-temurin-17-alpine AS build

# Accept project directory as a build argument
ARG WORK_DIR
WORKDIR /app

# Copy Maven config and scripts
COPY ${WORK_DIR}/pom.xml ./pom.xml
COPY build/maven/start.sh ./start.sh

# (Optional) Download dependencies for faster builds
# RUN mvn -B dependency:go-offline

# Copy the actual source code
COPY ${WORK_DIR}/src ./src

# Build the JAR (skip tests for faster build)
RUN mvn -B -f /app/pom.xml clean package -DskipTests


# ---------- Runtime Stage ----------
# Use a small, secure OpenJDK 17 runtime image
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /opt/egov

# Copy app artifacts and startup script from build stage
COPY --from=build /app/target/*.jar /app/start.sh /opt/egov/

# Ensure the start script is executable
RUN chmod +x /opt/egov/start.sh

# Set the container startup command
CMD ["/opt/egov/start.sh"]
