FROM quay.io/ukhomeofficedigital/docker-centos-base

RUN yum update -y -q; yum clean all
ADD logstash-1.5.repo /etc/yum.repos.d/logstash-1.5.repo
RUN yum install -y -q java-1.8.0-openjdk-headless.x86_64 logstash-1.5.4-1.noarch; yum clean all

RUN /opt/logstash/bin/plugin install logstash-filter-kubernetes
RUN /opt/logstash/bin/plugin install logstash-filter-json_encode
RUN /opt/logstash/bin/plugin install logstash-output-cloudwatchlogs

COPY run.sh /run.sh
COPY conf.d/ /etc/logstash/conf.d/

VOLUME /var/log/logstash

CMD ["/run.sh"]
