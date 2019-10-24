# Prebaked-registry
A docker-registry built with pre-baked container images in it


# Prerequisites:
- docker - installed and working
- github credentials configured (git clone public repo)
- avrez - installed and working
- jq installed
- Create a local credentials.env file with the following contents:
```.env
AVREZ_MANIFEST_GITHUB_ACCESS_TOKEN=<...>
ARTIFACTORY_USERNAME=<...>
ARTIFACTORY_PASSWORD=<...>
```