# Use official OpenJDK base image with version 11 (slim version)
FROM openjdk:11-jdk-slim

# Set the WILDFLY_VERSION environment variable
ENV WILDFLY_VERSION 19.0.0.Final
ENV WILDFLY_SHA1 0d47c0e8054353f3e2749c11214eab5bc7d78a14
ENV JBOSS_HOME /opt/jboss/wildfly

# Install curl and other necessary utilities, and create the user
RUN apt-get update && apt-get install -y curl && \
    mkdir /var/log/wezva && \
    adduser --disabled-password --gecos "" jboss && \
    chown jboss:jboss /var/log/wezva && \
    apt-get clean

# Download and install WildFly
RUN curl -fsSL https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz -o /tmp/wildfly.tar.gz && \
    echo "$WILDFLY_SHA1  /tmp/wildfly.tar.gz" | sha1sum -c - && \
    tar -xzf /tmp/wildfly.tar.gz -C /opt/jboss && \
    mv /opt/jboss/wildfly-$WILDFLY_VERSION $JBOSS_HOME && \
    rm /tmp/wildfly.tar.gz && \
    chown -R jboss:jboss $JBOSS_HOME && \
    chmod -R g+rw $JBOSS_HOME

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND=true

# Switch to non-root user
USER jboss

# Expose the application port
EXPOSE 8080

# Set the default command to run WildFly in standalone mode
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
