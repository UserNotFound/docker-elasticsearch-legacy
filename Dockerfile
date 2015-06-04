FROM quay.io/aptible/ubuntu:14.04

ENV DATA_DIRECTORY /var/db
RUN apt-get update

# Taken from dockerfile/java:oracle-java7
# Accept Oracle license agreement
RUN echo "oracle-java7-installer shared/accepted-oracle-license-v1-1 " \
         "select true" | debconf-set-selections
# Install Java 7 and clean up
RUN apt-get -y install software-properties-common && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && apt-get install -y oracle-java7-installer && \
    rm -rf /var/lib/apt/lists/*

# Install Elasticsearch and clean up
RUN apt-get -y install wget && cd /tmp && \
    wget http://bit.ly/elasticsearch-152 && tar xvzf elasticsearch-152 && \
    mv /tmp/elasticsearch-1.5.2 /elasticsearch && rm -rf elasticsearch-152

# Install NGiNX
RUN add-apt-repository -y ppa:nginx/stable && apt-get update && \
    apt-get -y install nginx && mkdir -p /etc/nginx/ssl

# Install htpasswd for HTTP Basic Auth
RUN apt-get -y install apache2-utils

# Install node.js and elasticdump tool for --dump/--restore options.
# https://github.com/taskrabbit/elasticsearch-dump
RUN wget -q -O - http://nodejs.org/dist/v0.12.4/node-v0.12.4-linux-x64.tar.gz | tar zxf - && \
    ln -s /node-v0.12.4-linux-x64/bin/node /usr/local/bin/ && \
    ln -s /node-v0.12.4-linux-x64/bin/npm /usr/local/bin/ && \
    npm install -g elasticdump

ADD templates/nginx.conf /etc/nginx/nginx.conf
ADD templates/nginx-wrapper /usr/sbin/nginx-wrapper

# Mount elasticsearch.yml config
ADD templates/elasticsearch.yml /elasticsearch/config/elasticsearch.yml

ADD run-database.sh /usr/bin/
ADD utilities.sh /usr/bin/

# Integration tests
ADD test /tmp/test
RUN bats /tmp/test

VOLUME ["$DATA_DIRECTORY"]

# Expose NGiNX proxy ports
EXPOSE 80

ENTRYPOINT ["run-database.sh"]
