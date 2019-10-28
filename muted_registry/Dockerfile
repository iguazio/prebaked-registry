# This is based on a minimal distribution container (https://github.com/docker/distribution-library-image/blob/master/Dockerfile.noarch)
# Only this container is not defining a volume on the /var/lib/registry (chmodding instead), to allow persisting of data INSIDE the docker iamge
# NOTE: This needs to be run in the correct docker-build context as part of git@github.com:docker/distribution-library-image,
# See relevant Makefile section
FROM alpine:3.8

RUN set -ex \
    && apk add --no-cache ca-certificates apache2-utils

COPY ./registry /bin/registry
COPY ./config-example.yml /etc/docker/registry/config.yml

# preperations for the data dir being internal
RUN addgroup -g 1000 -S registry && adduser -u 1000 -S registry -G registry
RUN mkdir -p /var/lib/registry && chown -R 1000:1000 /var/lib/registry

EXPOSE 5000

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/docker/registry/config.yml"]