RELEASE_REGISTRY_URL ?= quay.io/
RELEASE_REGISTRY_USER ?= iguazio
IGZ_NUCLIO_REGISTRY_VERSION ?= latest
IGZ_VERSION ?= REPLACEME # e.g. 2.5.0
BASE_DOCKER_REGISTRY_VERSION=2.7.1

# Usage examples:
# Build a nuclio pre-baked registry (version 1.0.0) for iguazio version 2.8.0
# > source ./credentials.env && IGZ_VERSION=2.8.0 IGZ_NUCLIO_REGISTRY_VERSION=1.0.0 make build
# Release the pre-baked nuclio registry (version 1.0.0) to quay.io/iguazio
# > IGZ_NUCLIO_REGISTRY_VERSION=1.0.0 make release-nuclio-registry

.PHONY: build
build: build-muted-registry build-nuclio-registry
	@echo "Done all"

.PHONY: build-muted-registry
build-muted-registry:
	rm -rf /tmp/distribution-library-image
	git clone git@github.com:docker/distribution-library-image.git /tmp/distribution-library-image
	cd /tmp/distribution-library-image && git checkout registry-$(BASE_DOCKER_REGISTRY_VERSION)
	docker build \
		--file muted_registry/Dockerfile \
		--tag iguazio/muted-registry:$(BASE_DOCKER_REGISTRY_VERSION) \
		/tmp/distribution-library-image/amd64
	rm -rf /tmp/distribution-library-image
	@echo "Done building muted-registry"

.PHONY: build-nuclio-registry
build-nuclio-registry:
	nuclio/build.sh --version=$(IGZ_NUCLIO_REGISTRY_VERSION) --igz-version=$(IGZ_VERSION) --base-registry-image=iguazio/muted-registry:$(BASE_DOCKER_REGISTRY_VERSION)

.PHONY: release-nuclio-registry
release-nuclio-registry:
	docker push $(RELEASE_REGISTRY_URL)$(RELEASE_REGISTRY_USER)/prebaked-registry-nuclio:$(IGZ_NUCLIO_REGISTRY_VERSION)
	@echo "Done releasing prebaked-registry-nuclio version=$(IGZ_NUCLIO_REGISTRY_VERSION)"
