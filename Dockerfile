FROM public.ecr.aws/docker/library/eclipse-temurin:21-jdk
LABEL maintainer="DevOps Team <devops@example.com>"
LABEL author="Lalit <lalit@example.com>"
LABEL description="Custom Docker image with metadata"
# Create non-root user
RUN useradd -m bookmytickets
# Set working directory
WORKDIR /app
# Copy jar file
COPY target/bookmytickets*.jar app.jar
# Change ownership to new user
RUN chown -R bookmytickets:bookmytickets /app
# Switch to non-root user
USER bookmytickets
# Expose port
EXPOSE 8080
# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]