#!/bin/sh

function build_target_to_tag() {
	docker build --target "$1" --tag "$2" .
}

function retag() {
	docker tag "$1" "$2"
}

VERSION="${VERSION:-latest}"

build_target_to_tag "base" "docker.io/kryestofer/lopenvas-base:${VERSION}" && \
build_target_to_tag "sync" "docker.io/kryestofer/lopenvas-sync:${VERSION}" && \
build_target_to_tag "openvas" "docker.io/kryestofer/lopenvas-openvas:${VERSION}" && \
build_target_to_tag "gvmd" "docker.io/kryestofer/lopenvas-gvmd:${VERSION}" && \
build_target_to_tag "gvmd-db" "docker.io/kryestofer/lopenvas-postgres:${VERSION}" && \
build_target_to_tag "gsad" "docker.io/kryestofer/lopenvas-gsad:${VERSION}"
