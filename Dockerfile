# Use the latest secure base image
FROM openjdk:11-jdk-slim

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION=19.0.0.Final \
    JBOSS_HOME=/opt/jboss/wildfly \
    WILDFLY_SHA1=0d47c0e8054353f3e2749c11214eab5bc7d78a14

USER root

# Combine RUN commands to reduce layers and install curl securely
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /var/log/wezva && chown jboss:jboss /var/log/wezva && \
    curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz && \
    echo "$WILDFLY_SHA1 wildfly-$WILDFLY_VERSION.tar.gz" | sha1sum -c - && \
    tar xf wildfly-$WILDFLY_VERSION.tar.gz -C /opt && \
    mv /opt/wildfly-$WILDFLY_VERSION $JBOSS_HOME && \
    rm wildfly-$WILDFLY_VERSION.tar.gz && \
    chown -R jboss:jboss ${JBOSS_HOME} && \
    chmod -R g+rw ${JBOSS_HOME} && \
    apt-get purge -y --auto-remove curl

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND=true

USER jboss

# Expose the ports we're interested in
EXPOSE 8080

# Set the default command to run on boot
# This will boot Wildfly in the standalone mode and bind to all interface
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
