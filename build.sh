#!/bin/sh

function build_target_to_tag() {
	docker build --target "$1" --tag "$2" .
	echo "\a"
}

VERSION="${VERSION:-latest}"

build_target_to_tag "base" "openvas-docker/base:${VERSION}"
build_target_to_tag "sync" "openvas-docker/sync:${VERSION}"
build_target_to_tag "openvas" "openvas-docker/openvas:${VERSION}"
build_target_to_tag "gvmd" "openvas-docker/gvmd:${VERSION}"
build_target_to_tag "gsad" "openvas-docker/gsad:${VERSION}"
