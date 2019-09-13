#!/bin/sh

VERSION="${VERSION:-latest}"

docker push "docker.io/kryestofer/lopenvas-base:${VERSION}" && \
docker push "docker.io/kryestofer/lopenvas-sync:${VERSION}" && \
docker push "docker.io/kryestofer/lopenvas-openvas:${VERSION}" && \
docker push "docker.io/kryestofer/lopenvas-gvmd:${VERSION}" && \
docker push "docker.io/kryestofer/lopenvas-gsad:${VERSION}"
