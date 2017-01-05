FROM fedora:25

RUN dnf upgrade -y -q && \
    dnf clean all && \
    dnf install -y -q java-headless which hostname tar wget && \
    dnf clean all

ENV LS_VERSION 5.1.1
RUN wget -q https://artifacts.elastic.co/downloads/logstash/logstash-${LS_VERSION}.tar.gz -O - | tar -xzf -; \
  mv logstash-${LS_VERSION} /logstash

RUN /logstash/bin/logstash-plugin install --version 5.4.0 logstash-output-elasticsearch && \
    /logstash/bin/logstash-plugin install --version 0.3.1 logstash-filter-kubernetes && \
    /logstash/bin/logstash-plugin install --version 2.0.0 logstash-input-journald


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
