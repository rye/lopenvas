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

fetch_intermediate "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.2.13.tar.bz2"
fetch_intermediate "https://gnupg.org/ftp/gcrypt/gpgme/gpgme-1.12.0.tar.bz2"
fetch_intermediate "https://gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.3.tar.bz2"
fetch_intermediate "https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.35.tar.gz"
fetch_intermediate "https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.4.tar.gz"
fetch_intermediate "https://gnupg.org/ftp/gcrypt/libksba/libksba-1.3.5.tar.bz2"
fetch_intermediate "https://gnupg.org/ftp/gcrypt/npth/npth-1.6.tar.bz2"
fetch_intermediate "https://gnupg.org/ftp/gcrypt/ntbtls/ntbtls-0.1.2.tar.bz2"

fetch_intermediate "ftp://xmlsoft.org/libxslt/libxslt-1.1.33.tar.gz"

fetch_intermediate "https://github.com/Kitware/CMake/releases/download/v3.14.0/cmake-3.14.0.tar.gz"
fetch_intermediate "https://github.com/greenbone/gsa/archive/v7.0.3.tar.gz" "$ROOT/gsa-7.0.3.tar.gz"
fetch_intermediate "https://github.com/greenbone/gvm-libs/archive/v9.0.3.tar.gz" "$ROOT/gvm-libs--9.0.3.tar.gz"
fetch_intermediate "https://github.com/greenbone/gvmd/archive/v7.0.3.tar.gz" "$ROOT/gvmd-7.0.3.tar.gz"
fetch_intermediate "https://github.com/greenbone/openvas-scanner/archive/v5.1.3.tar.gz" "$ROOT/openvas-scanner--5.1.3.tar.gz"
fetch_intermediate "https://github.com/greenbone/openvas-smb/archive/v1.0.4.tar.gz" "$ROOT/openvas-smb--1.0.4.tar.gz"

pushd "$ROOT"

sha256sum -c SHA256SUMS
