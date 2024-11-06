# Start with a smaller base image for efficiency
FROM openjdk:11-jdk-slim

ENV WILDFLY_VERSION=20.0.1.Final \
    JBOSS_HOME=/opt/jboss/wildfly \
    WILDFLY_SHA1=0d47c0e8054353f3e2749c11214eab5bc7d78a14

USER root

RUN apt-get update && apt-get install -y curl && \
    mkdir -p /var/log/wezva && chown -R jboss:jboss /var/log/wezva && \
    curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz && \
    echo "$WILDFLY_SHA1 wildfly-$WILDFLY_VERSION.tar.gz" | sha1sum -c - && \
    tar -xzf wildfly-$WILDFLY_VERSION.tar.gz -C /opt && \
    mv /opt/wildfly-$WILDFLY_VERSION $JBOSS_HOME && \
    rm wildfly-$WILDFLY_VERSION.tar.gz && \
    chown -R jboss:jboss $JBOSS_HOME

USER jboss

EXPOSE 8080

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
