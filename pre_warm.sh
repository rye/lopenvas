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

fetch_intermediate "https://github.com/greenbone/gsa/archive/v8.0.1.tar.gz" "$ROOT/gsa-8.0.1.tar.gz"
fetch_intermediate "https://github.com/greenbone/gsa/archive/v9.0.0.tar.gz" "$ROOT/gsa-9.0.0.tar.gz"
fetch_intermediate "https://github.com/greenbone/gvm-libs/archive/v10.0.1.tar.gz" "$ROOT/gvm-libs--10.0.1.tar.gz"
fetch_intermediate "https://github.com/greenbone/gvm-libs/archive/v11.0.0.tar.gz" "$ROOT/gvm-libs--11.0.0.tar.gz"
fetch_intermediate "https://github.com/greenbone/gvmd/archive/v8.0.1.tar.gz" "$ROOT/gvmd-8.0.1.tar.gz"
fetch_intermediate "https://github.com/greenbone/openvas/archive/v6.0.1.tar.gz" "$ROOT/openvas--6.0.1.tar.gz"
fetch_intermediate "https://github.com/greenbone/openvas-smb/archive/v1.0.4.tar.gz" "$ROOT/openvas-smb--1.0.4.tar.gz"

pushd "$ROOT"

sha256sum -c SHA256SUMS
