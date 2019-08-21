#!/bin/sh

function build_target_to_tag() {
	docker build --target "$1" --tag "$2" .
}

function retag() {
	docker tag "$1" "$2"
}

VERSION="${VERSION:-latest}"

build_target_to_tag "base" "docker.io/lopenvas/base:${VERSION}" && \
	retag "docker.io/lopenvas/base:${VERSION}" "docker.pkg.github.com/rye/lopenvas/base:${VERSION}" && \
build_target_to_tag "sync" "docker.io/lopenvas/sync:${VERSION}" && \
	retag "docker.io/lopenvas/sync:${VERSION}" "docker.pkg.github.com/rye/lopenvas/sync:${VERSION}" && \
build_target_to_tag "openvas" "docker.io/lopenvas/openvas:${VERSION}" && \
	retag "docker.io/lopenvas/openvas:${VERSION}" "docker.pkg.github.com/rye/lopenvas/openvas:${VERSION}" && \
build_target_to_tag "gvmd" "docker.io/lopenvas/gvmd:${VERSION}" && \
	retag "docker.io/lopenvas/gvmd:${VERSION}" "docker.pkg.github.com/rye/lopenvas/gvmd:${VERSION}" && \
build_target_to_tag "gvmd-db" "docker.io/lopenvas/postgres:${VERSION}" && \
	retag "docker.io/lopenvas/postgres:${VERSION}" "docker.pkg.github.com/rye/lopenvas/postgres:${VERSION}" && \
build_target_to_tag "gsad" "docker.io/lopenvas/gsad:${VERSION}" && \
	retag "docker.io/lopenvas/gsad:${VERSION}" "docker.pkg.github.com/rye/lopenvas/gsad:${VERSION}"
