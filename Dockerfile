
# Based on https://github.com/wurstmeister/kafka-docker/blob/master/Dockerfile & https://github.com/wurstmeister/zookeeper-docker/blob/master/Dockerfile

ARG kafka_version=2.5.0
ARG scala_version=2.12

FROM adoptopenjdk/openjdk8:debian-slim as BUILD

ARG kafka_version
ARG scala_version

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version

RUN set -ex; \
    apt-get update; \
    apt-get -y install wget gpg; \
    rm -rf /var/lib/apt/lists/*

#Download Kafka
RUN wget -q https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz; \
    wget -q https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz.sha512; \
    wget -q https://downloads.apache.org/kafka/KEYS; \
    wget -q https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz.asc

#Verify download
RUN sha512sum -c kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz.sha512; \
    gpg --import KEYS; \
    gpg --verify kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz.asc


FROM adoptopenjdk/openjdk8:debian-slim

ARG kafka_version
ARG scala_version

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka \
    PATH=${PATH}:${KAFKA_HOME}/bin

#Dependencies
RUN set -ex; \
    apt-get update; \
    apt-get -y install jq net-tools gnupg; \
    curl -fsSL https://download.docker.com/linux/raspbian/gpg | apt-key add -qq - >/dev/null; \
    echo "deb [arch=armhf] https://download.docker.com/linux/raspbian buster stable" > /etc/apt/sources.list.d/docker.list; \
    apt-get update; \
    apt-get -y install docker-ce-cli; \
    apt-get -y autoremove; \
    rm -rf /var/lib/apt/lists/*

#Install
COPY --from=BUILD kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz /
RUN tar -xzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt; \
    ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME}; \
    rm kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

COPY start-kafka.sh broker-list.sh create-topics.sh versions.sh /usr/bin/

COPY overrides /opt/overrides

VOLUME ["/kafka"]

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]