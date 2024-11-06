# Use a base image with Java installed, such as OpenJDK
FROM openjdk:8-jdk-alpine

# Set environment variables
ENV WILDFLY_VERSION=19.0.0.Final
ENV JBOSS_HOME=/opt/jboss/wildfly
ENV WILDFLY_SHA1=0d47c0e8054353f3e2749c11214eab5bc7d78a14

# Create a non-root user to run WildFly
RUN adduser -D jboss && \
    mkdir -p /opt/jboss && \
    chown jboss:jboss /opt/jboss

# Download and install WildFly
RUN curl -fsSL https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz -o /tmp/wildfly.tar.gz && \
    echo "$WILDFLY_SHA1  /tmp/wildfly.tar.gz" | sha1sum -c - && \
    mkdir -p /opt/jboss && \
    tar -xzf /tmp/wildfly.tar.gz -C /opt/jboss && \
    mv /opt/jboss/wildfly-$WILDFLY_VERSION /opt/jboss/wildfly && \
    rm /tmp/wildfly.tar.gz && \
    chown -R jboss:jboss /opt/jboss/wildfly && \
    chmod -R g+rw /opt/jboss/wildfly

# Expose necessary ports
EXPOSE 8080 9990

# Set the working directory
WORKDIR $JBOSS_HOME

# Set the user to non-root (jboss) for running WildFly
USER jboss

# Start WildFly in standalone mode
CMD ["./bin/standalone.sh", "-b", "0.0.0.0"]
