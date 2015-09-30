# docker-logstash-kubernetes

Logstash container for pulling docker logs with kubernetes metadata support.
Events can be pushed to Cloudwatch Logs.

Other outputs can be added in the future.

## Requirements

You need to have kubelet process running on the host. Normally kubelet creates
symlinks to container logs from `/var/log/containers/` to
`/var/lib/docker/containers/`. So for that you need to make sure that logstash
has access to both directories.

Also, logstash writes `sincedb` file to its home directory, which by default is
`/var/lib/logstash`. If you don't want logstash to start reading docker logs
from the beginning after a restart, make sure you mount `/var/lib/logstash`
somewhere on the host.

If you want to push events to Cloudwatch Logs, then you will have to set AWS
access keys via environment variables.


## Configuration

As usual, configuration is passed through environment variables.

### Logstash

- `LS_HEAP_SIZE` - logstash JVM heap size. Defaults to `500m`.

### Cloudwatch Logs

- `OUTPUT_CLOUDWATCH` - whether to enable this output. Defaults to `true`.
- `AWS_REGION` - defaults to `eu-west-1`.
- `AWS_ACCESS_KEY_ID` - must be set.
- `AWS_SECRET_ACCESS_KEY` - must be set.
- `LOG_GROUP_NAME` - Cloudwatch logs group name. Defaults to `logstash`.
- `LOG_STREAM_NAME` - Cloudwatch logs stream name. Defaults to `kubernetes`.


## Running

```
$ docker run -ti --rm \
    -v /var/lib/logstash-kubernetes:/var/lib/logstash
    -v /var/lib/docker/containers:/var/lib/docker/containers \
    -v /var/log/containers:/var/log/containers
    -e AWS_REGION=us-west-1 \
    -e AWS_ACCESS_KEY_ID=<REPLACE ME> \
    -e AWS_SECRET_ACCESS_KEY=<REPLACE ME> \
    quay.io/ukhomeofficedigital/logstash-kubernetes:latest
```
