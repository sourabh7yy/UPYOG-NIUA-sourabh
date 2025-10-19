# ---------- Build Stage ----------
FROM upyogio/alpine-maven-builder-jdk-17:1-master-NA-6036091e AS build
# Alternative (if you want to use the upstream image instead of upyogio’s):
# FROM ghcr.io/egovernments/alpine-maven-builder-jdk-17:1-master-na-6036091e AS build

ARG WORK_DIR
WORKDIR /app

# Copy project files
COPY ${WORK_DIR}/pom.xml ./pom.xml
COPY build/maven/start.sh ./start.sh

# Pre-download dependencies (optional for faster builds)
# RUN mvn -B dependency:go-offline

COPY ${WORK_DIR}/src ./src
RUN mvn -B -f /app/pom.xml clean package -DskipTests

# ---------- Runtime Stage ----------
FROM upyogio/17-openjdk-alpine
# Alternative (if using eGovernments GHCR image):
# FROM ghcr.io/egovernments/17-openjdk-alpine:latest

WORKDIR /opt/egov

# Copy app JAR and start script from build stage
COPY --from=build /app/target/*.jar /app/start.sh /opt/egov/

RUN chmod +x /opt/egov/start.sh

# Run the application
CMD ["/opt/egov/start.sh"]
