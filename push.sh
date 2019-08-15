#!/bin/sh

VERSION="${VERSION:-latest}"

docker push "lopenvas/base:${VERSION}" && \
docker push "lopenvas/sync:${VERSION}" && \
docker push "lopenvas/openvas:${VERSION}" && \
docker push "lopenvas/gvmd:${VERSION}" && \
docker push "lopenvas/gsad:${VERSION}"
