#!/usr/bin/env bash

set -e

for i in "$@"
do
case $i in
    -v=*|--version=*)
    VERSION="${i#*=}"
    shift # past argument=value
    ;;

    -iv=*|--igz-version=*)
    IGZ_VERSION="${i#*=}"
    shift # past argument=value
    ;;

    -bri=*|--base-registry-image=*)
    BASE_REGISTRY_IMAGE="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

if [[ -z ${VERSION} ]]; then
    printf "VERSION not provided, cannot perform release\n"
    exit 1
fi

if [[ -z ${BASE_REGISTRY_IMAGE} ]]; then
    printf "BASE_REGISTRY_IMAGE not provided, cannot perform release\n"
    exit 1
fi

printf "VERSION              = ${VERSION}\n"
printf "BASE_REGISTRY_IMAGE  = ${BASE_REGISTRY_IMAGE}\n"
printf "\n"

printf "\n## Sourcing credentials.env file (See README.md)\n"
source credentials.env

printf "\n## Releasing prebaked-registry-nuclio version ${VERSION}, with images from nuclio ${VERSION}\n"

docker rm -f prebaked-registry-nuclio || true

printf "\n## Running local registry: ${BASE_REGISTRY_IMAGE} \n"
docker run --user 1000:1000 --rm -d -p 5000:5000 --name=prebaked-registry-nuclio ${BASE_REGISTRY_IMAGE}

IMAGES_TO_BAKE=(
"quay.io/nuclio/handler-builder-python-onbuild:${VERSION}-amd64"
"quay.io/nuclio/handler-builder-golang-onbuild:${VERSION}-amd64"
"quay.io/nuclio/handler-builder-nodejs-onbuild:${VERSION}-amd64"
"quay.io/nuclio/handler-builder-java-onbuild:${VERSION}-amd64"
"quay.io/nuclio/handler-builder-dotnetcore-onbuild:${VERSION}-amd64"
"quay.io/nuclio/handler-builder-ruby-onbuild:${VERSION}-amd64"
)

printf "\nResolved images to bake:\n"
printf '%s\n' "${IMAGES_TO_BAKE[@]}"

for ORIG_IMAGE in "${IMAGES_TO_BAKE[@]}"
do
  printf "\n### Pulling docker image\n"
  docker pull $ORIG_IMAGE

  declare RETAGGED_IMAGE
  RETAGGED_IMAGE=${ORIG_IMAGE/"quay.io"/"localhost:5000"}

  printf "\n### Tagging image to local prebaked registry\n"
  docker tag $ORIG_IMAGE $RETAGGED_IMAGE

  printf "\n### Pushing image to prebaked registry\n"
  docker push $RETAGGED_IMAGE
done

printf "\n## View catalog - Listing baked images in registry\n"
http get localhost:5000/v2/_catalog

printf "\n## Commiting prebaked local registry image\n"
declare NUCLIO_REGISTRY_IMAGE
NUCLIO_REGISTRY_IMAGE="quay.io/iguazio/prebaked-registry-nuclio:${VERSION}"

docker commit --message "Baking nuclio images for ${IGZ_VERSION}" prebaked-registry-nuclio $NUCLIO_REGISTRY_IMAGE
docker rm -f prebaked-registry-nuclio
printf "\n## Completed building prebaked-registry for nuclio - image: ${NUCLIO_REGISTRY_IMAGE}\n"

# For visual verification
printf "\n## Running prebaked local registry to validate content\n"
docker run --user 1000:1000 --rm -d -p 5000:5000 --name=prebaked-registry-nuclio quay.io/iguazio/prebaked-registry-nuclio:${VERSION}
http get localhost:5000/v2/_catalog
docker rm -f prebaked-registry-nuclio
