#!/bin/sh

function build_target_to_tag() {
	docker build --target "$1" --tag "$2" .
}

function retag() {
	docker tag "$1" "$2"
}

VERSION="${VERSION:-latest}"

build_target_to_tag "base" "docker.pkg.github.com/rye/lopenvas/base:${VERSION}" && \
build_target_to_tag "sync" "docker.pkg.github.com/rye/lopenvas/sync:${VERSION}" && \
build_target_to_tag "openvas" "docker.pkg.github.com/rye/lopenvas/openvas:${VERSION}" && \
build_target_to_tag "gvmd" "docker.pkg.github.com/rye/lopenvas/gvmd:${VERSION}" && \
build_target_to_tag "gvmd-db" "docker.pkg.github.com/rye/lopenvas/postgres:${VERSION}" && \
build_target_to_tag "gsad" "docker.pkg.github.com/rye/lopenvas/gsad:${VERSION}"
