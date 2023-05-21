# These are the latest combinations of versions available on dockerhub and the Ubuntu
# PPAs as of 2023/05/06
FROM apache/flink:1.16.0-scala_2.12-java11
ARG FLINK_VERSION=1.16.0

# Install pre-reqs to add new PPA
RUN set -ex; \
    apt-get update && \
    # Install the pre-req to be able to add PPAs before installing python
    apt-get install -y software-properties-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install python3 and pip3
RUN apt-get update -y && \
    apt-get install -y python3 python3-pip python3-dev && rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN pip install --upgrade google-api-python-client; \
    pip install apache-flink==${FLINK_VERSION}; \
    pip install kafka-python;

# Download connector libraries
ARG FLINK_MAVEN_URL="https://repo.maven.apache.org/maven2/org/apache/flink"
RUN wget -P /opt/flink/lib/ ${FLINK_MAVEN_URL}/flink-json/${FLINK_VERSION}/flink-json-${FLINK_VERSION}.jar; \
    wget -P /opt/flink/lib/ ${FLINK_MAVEN_URL}/flink-sql-connector-kafka/${FLINK_VERSION}/flink-sql-connector-kafka-${FLINK_VERSION}.jar; \
    wget -P /opt/flink/lib/ ${FLINK_MAVEN_URL}/flink-connector-jdbc/${FLINK_VERSION}/flink-connector-jdbc-${FLINK_VERSION}.jar;

RUN echo "taskmanager.memory.jvm-metaspace.size: 512m" >> /opt/flink/conf/flink-conf.yaml;

WORKDIR /opt/flink
