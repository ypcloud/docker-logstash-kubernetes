#!/usr/bin/bash

: ${LS_HOME:=/var/lib/logstash}
: ${HOME:=${LS_HOME}}
: ${LS_HEAP_SIZE:=500m}
: ${LS_JAVA_OPTS:=-Djava.io.tmpdir=${LS_HOME}}
: ${LS_LOG_DIR:=/var/log/logstash}
: ${OUTPUT_CLOUDWATCH:=true}
: ${AWS_REGION:=eu-west-1}
: ${LOG_GROUP_NAME:=logstash}
: ${LOG_STREAM_NAME:=kubernetes}

sed -e "s/%AWS_REGION%/${AWS_REGION}/" \
    -e "s/%LOG_GROUP_NAME%/${LOG_GROUP_NAME}/" \
    -e "s/%LOG_STREAM_NAME%/${LOG_STREAM_NAME}/" \
    -i /etc/logstash/conf.d/20_output_kubernetes_cloudwatch.conf

if [[ ${OUTPUT_CLOUDWATCH} != 'true' ]]; then
  rm -f /etc/logstash/conf.d/20_output_kubernetes_cloudwatch.conf
fi

ulimit -n ${LS_OPEN_FILES} > /dev/null
cd ${LS_HOME}

/opt/logstash/bin/logstash -f /etc/logstash/conf.d
