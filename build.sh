#!/bin/sh

function build_target_to_tag() {
	docker build --target "$1" --tag "$2" .
}

function retag() {
	docker tag "$1" "$2"
}

VERSION="${VERSION:-latest}"

build_target_to_tag "base" "lopenvas-base:${VERSION}" && \
build_target_to_tag "sync" "lopenvas-sync:${VERSION}" && \
build_target_to_tag "openvas" "lopenvas-openvas:${VERSION}" && \
build_target_to_tag "gvmd" "lopenvas-gvmd:${VERSION}" && \
build_target_to_tag "gvmd-db" "lopenvas-postgres:${VERSION}" && \
build_target_to_tag "gsad" "lopenvas-gsad:${VERSION}"
