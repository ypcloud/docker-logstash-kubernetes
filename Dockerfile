FROM fedora:25

# S3 variables
ENV AWS_ACCESS_KEY_ID SOMETHING
ENV AWS_SECRET_ACCESS_KEY SOMETHINGELSE
ENV AWS_REGION eu-west-1
ENV AWS_BUCKET commons-dev-logs
ENV AWS_SIZE_FILE 2048
ENV AWS_TIME_FILE 5
ENV AWS_CANNED_ACL private

RUN dnf upgrade -y -q && \
    dnf clean all && \
    dnf install -y -q java-headless which hostname tar wget && \
    dnf clean all

ENV LS_VERSION 5.1.1
RUN wget -q https://artifacts.elastic.co/downloads/logstash/logstash-${LS_VERSION}.tar.gz -O - | tar -xzf -; \
  mv logstash-${LS_VERSION} /logstash

RUN /logstash/bin/logstash-plugin install --version 5.4.0 logstash-output-elasticsearch && \
    /logstash/bin/logstash-plugin install --version 0.3.1 logstash-filter-kubernetes && \
    /logstash/bin/logstash-plugin install --version 2.0.0 logstash-input-journald && \
    /logstash/bin/logstash-plugin install logstash-output-s3


COPY run.sh /run.sh
COPY conf.d/ /logstash/conf.d/

RUN set -ex; \
# if the "log4j2.properties" file exists (logstash 5.x), let's empty it out 
# so we get the default: "logging only errors to the console"
  if [ -f "/logstash/config/log4j2.properties" ]; then \
    cp "/logstash/config/log4j2.properties" "/logstash/config/log4j2.properties.dist"; \
    truncate --size=0 "/logstash/config/log4j2.properties"; \
  fi

WORKDIR /var/lib/logstash
VOLUME /var/lib/logstash

ENTRYPOINT ["/run.sh"]
