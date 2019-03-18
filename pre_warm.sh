#!/bin/bash

set -x

ROOT="$(dirname $0)/var"

mkdir -pv "$ROOT"

fetch_intermediate() {
	if [ -z "$2" ];
	then
		wget -N -P "$ROOT" "$1"
	else
		wget -O "$2" "$1"
	fi
}

fetch_intermediate "https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.35.tar.gz"
fetch_intermediate "https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.4.tar.gz"

pushd "$ROOT"

sha256sum -c SHA256SUMS
