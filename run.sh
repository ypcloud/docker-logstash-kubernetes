#!/usr/bin/bash

export HOME=/var/lib/logstash

: ${LS_HEAP_SIZE:=500m}
: ${LS_JAVA_OPTS:=-Djava.io.tmpdir=${HOME}}
: ${LS_LOG_DIR:=/var/lib/logstash}
: ${LS_OPEN_FILES:=8192}

: ${INPUT_JOURNALD:=true}

: ${OUTPUT_CLOUDWATCH:=false}
: ${AWS_REGION:=eu-west-1}
: ${LOG_GROUP_NAME:=logstash}
: ${LOG_STREAM_NAME:=$(hostname)}

: ${OUTPUT_S3=:false}
: ${AWS_ACCESS_KEY:=""}
: ${AWS_SECRET_ACCESS_KEY:=""}
: ${AWS_BUCKET:=""}

: ${OUTPUT_ELASTICSEARCH:=true}
: ${ELASTICSEARCH_HOST:=127.0.0.1:9200}
: ${ELASTICSEARCH_INDEX_SUFFIX:=""}


if [[ ${INPUT_JOURNALD} != 'true' ]]; then
  rm -f /logstash/conf.d/10_input_journald.conf
fi

if [[ ${OUTPUT_S3} != 'true' ]]; then
  rm -rf /logstash/conf.d/20_output_kubernetes_s3.conf
else
  sed -e "s/%AWS_ACCESS_KEY_ID%/${AWS_ACCESS_KEY_ID}/" \
      -e "s/%AWS_SECRET_ACCESS_KEY%/${AWS_SECRET_ACCESS_KEY}/" \
      -e "s/%AWS_REGION%/${AWS_REGION}/" \
      -e "s/%AWS_BUCKET%/${AWS_BUCKET}/" \
      -e "s/%AWS_SIZE_FILE%/${AWS_SIZE_FILE}/" \
      -e "s/%AWS_TIME_FILE%/${AWS_TIME_FILE}/" \
      -e "s/%AWS_CANNED_ACL%/${AWS_CANNED_ACL}/" \
      -i /logstash/conf.d/20_output_kubernetes_s3.conf
fi


if [[ ${OUTPUT_ELASTICSEARCH} != 'true' ]]; then
  rm -f /logstash/conf.d/20_output_journald_elasticsearch.conf
  rm -f /logstash/conf.d/20_output_kubernetes_elasticsearch.conf
else
  sed -e "s/%ELASTICSEARCH_HOST%/${ELASTICSEARCH_HOST}/" \
      -i /logstash/conf.d/20_output_kubernetes_elasticsearch.conf \
      -i /logstash/conf.d/20_output_journald_elasticsearch.conf
  sed -e "s/%ELASTICSEARCH_INDEX_SUFFIX%/${ELASTICSEARCH_INDEX_SUFFIX}/" \
      -i /logstash/conf.d/20_output_kubernetes_elasticsearch.conf \
      -i /logstash/conf.d/20_output_journald_elasticsearch.conf
fi


if [[ ${OUTPUT_CLOUDWATCH} != 'true' ]]; then
  rm -f /logstash/conf.d/20_output_kubernetes_cloudwatch.conf
  rm -f /logstash/conf.d/20_output_journald_cloudwatch.conf
else
  sed -e "s/%AWS_REGION%/${AWS_REGION}/" \
      -e "s/%LOG_GROUP_NAME%/${LOG_GROUP_NAME}/" \
      -e "s/%LOG_STREAM_NAME%/${LOG_STREAM_NAME}/" \
      -i /logstash/conf.d/20_output_kubernetes_cloudwatch.conf \
      -i /logstash/conf.d/20_output_journald_cloudwatch.conf
fi


ulimit -n ${LS_OPEN_FILES} > /dev/null

exec /logstash/bin/logstash --log.format json -f /logstash/conf.d ${LOGSTASH_ARGS}
