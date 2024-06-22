# Stage 1: Build the application
FROM gradle:jdk-21-and-22-graal-jammy AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the Gradle wrapper and build files
COPY gradle /app/gradle
COPY gradlew /app/gradlew
COPY build.gradle.kts /app/build.gradle.kts
COPY settings.gradle.kts /app/settings.gradle.kts

# Copy the source code
COPY src /app/src

RUN chmod +x /app/gradlew

RUN ls -la && pwd

# Build the application
RUN gradle build --no-daemon

# Stage 2: Create the runtime image
FROM gradle:jdk-21-and-22-graal-jammy

# Set the working directory inside the container
WORKDIR /app

# Copy the built application from the previous stage
COPY --from=build /app/build/libs/*.jar app.jar

# Expose the port the application will run on
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
