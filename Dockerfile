FROM quay.io/ukhomeofficedigital/centos-base:v0.2.0

RUN yum update -y -q; yum clean all
RUN yum install -y -q java-headless which hostname tar wget; yum clean all

ENV LS_VERSION 2.2.2
RUN wget -q https://download.elastic.co/logstash/logstash/logstash-2.2.2.tar.gz -O - | tar -xzf -; \
  mv logstash-${LS_VERSION} /logstash

RUN /logstash/bin/plugin install logstash-filter-kubernetes
RUN /logstash/bin/plugin install logstash-input-journald
RUN /logstash/bin/plugin install --version 2.0.0.pre1 logstash-output-cloudwatchlogs

COPY run.sh /run.sh
COPY conf.d/ /logstash/conf.d/

WORKDIR /var/lib/logstash
VOLUME /var/lib/logstash

CMD ["/run.sh"]
