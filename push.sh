#!/bin/sh

VERSION="${VERSION:-latest}"

docker push "docker.pkg.github.com/rye/lopenvas/base:${VERSION}" && \
docker push "docker.pkg.github.com/rye/lopenvas/sync:${VERSION}" && \
docker push "docker.pkg.github.com/rye/lopenvas/openvas:${VERSION}" && \
docker push "docker.pkg.github.com/rye/lopenvas/gvmd:${VERSION}" && \
docker push "docker.pkg.github.com/rye/lopenvas/gsad:${VERSION}"
