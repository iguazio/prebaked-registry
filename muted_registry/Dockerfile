# This is based on a minimal distribution container (https://github.com/docker/distribution-library-image/blob/master/Dockerfile.noarch)
# Only this container is not defining a volume on the /var/lib/registry, to allow persisting of data INSIDE the docker iamge
# NOTE: This needs to be run in the correct docker-build context as part of git@github.com:docker/distribution-library-image,
# See relevant Makefile section
FROM alpine:3.8

RUN set -ex \
    && apk add --no-cache ca-certificates apache2-utils

COPY ./registry /bin/registry
COPY ./config-example.yml /etc/docker/registry/config.yml

EXPOSE 5000

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/docker/registry/config.yml"]