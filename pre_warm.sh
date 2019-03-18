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
fetch_intermediate "https://github.com/Kitware/CMake/releases/download/v3.14.0/cmake-3.14.0.tar.gz" "$ROOT/cmake-3.14.0.tar.gz"
fetch_intermediate "https://github.com/greenbone/gsa/archive/v7.0.3.tar.gz" "$ROOT/gsa-7.0.3.tar.gz"
fetch_intermediate "https://github.com/greenbone/gvm-libs/archive/v9.0.3.tar.gz" "$ROOT/gvm-libs--9.0.3.tar.gz"
fetch_intermediate "https://github.com/greenbone/gvmd/archive/v7.0.3.tar.gz" "$ROOT/gvmd-7.0.3.tar.gz"
fetch_intermediate "https://github.com/greenbone/openvas-scanner/archive/v5.1.3.tar.gz" "$ROOT/openvas-scanner--5.1.3.tar.gz"

pushd "$ROOT"

sha256sum -c SHA256SUMS
