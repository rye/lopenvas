FROM debian:buster-slim AS base

RUN mkdir -pv /usr/local/var/run && apt-get update && apt-get -qy install \
	heimdal-multidev \
	libglib2.0-0 \
	libgnutls30 \
	libgpgme11 \
	libhiredis0.14 \
	libksba8 \
	libldap-2.4-2 \
	libpcap0.8 \
	libpopt0 \
	libsnmp30 \
	libssh-4 \
	libssh2-1

FROM base AS build-deps

RUN apt-get update && apt-get -qy install \
	bison \
	build-essential \
	cmake \
	curl \
#	doxygen \
#	file \
	gcc-mingw-w64 \
	git \
	libglib2.0-dev \
	libgnutls28-dev \
	libgpgme-dev \
	libhiredis-dev \
	libksba-dev \
	libksba-mingw-w64-dev \
	libldap2-dev \
	libpcap-dev \
	libpopt-dev \
	libsnmp-dev \
	libssh-dev \
	libssh2-1-dev \
#	glibc-source \
#	libgcrypt-dev \
#	libgpg-error-dev \
#	libsnmp-base \
#	libuuid1 \
#	libxslt-dev \
#	snmp \
	pkg-config
#	wget \
#	zlib1g-dev

ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig

FROM build-deps AS gvm-libs-heavy

ENV GVM_LIBS_ARCHIVE="gvm-libs--10.0.0.tar.gz"
ENV OPENVAS_SMB_ARCHIVE="openvas-smb--1.0.4.tar.gz"
ADD var/$GVM_LIBS_ARCHIVE /opt
ADD var/$OPENVAS_SMB_ARCHIVE /opt

RUN mv /opt/gvm-libs-* /opt/gvm-libs
WORKDIR /opt/gvm-libs
RUN cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_C_FLAGS=-Wno-deprecations . && make && make install && make clean

RUN mv /opt/openvas-smb-* /opt/openvas-smb
WORKDIR /opt/openvas-smb
RUN cmake -D CMAKE_BUILD_TYPE=Release . && make && make install && make clean

FROM base AS gvm-libs

COPY --from=gvm-libs-heavy /usr/local/bin/winexe /usr/local/bin/wmic /usr/local/bin/
COPY --from=gvm-libs-heavy /usr/local/lib/libopenvas_wmi*.so /usr/local/lib/
COPY --from=gvm-libs-heavy /usr/local/lib/libgvm_*.so /usr/local/lib/

## TARGET: openvas-scanner

FROM gvm-libs-heavy AS openvas-scanner-heavy

ENV OPENVAS_SCANNER_ARCHIVE="openvas-scanner--6.0.0.tar.gz"
ADD var/$OPENVAS_SCANNER_ARCHIVE /opt

RUN mv /opt/openvas-scanner-* /opt/openvas-scanner
WORKDIR /opt/openvas-scanner
RUN cmake -D CMAKE_BUILD_TYPE=Release . && make && make install && make clean

FROM gvm-libs AS openvas-scanner

COPY --from=openvas-scanner-heavy /usr/local/lib/libopenvas*.so /usr/local/lib/
COPY --from=openvas-scanner-heavy /usr/local/var/log/gvm/ /usr/local/var/log/
COPY --from=openvas-scanner-heavy /usr/local/etc/openvas/ /usr/local/etc/
COPY --from=openvas-scanner-heavy /usr/local/sbin/greenbone* /usr/local/sbin/openvassd /usr/local/sbin/
COPY --from=openvas-scanner-heavy /usr/local/bin/openvas* /usr/local/bin/
RUN ldconfig

ENTRYPOINT ["/usr/local/sbin/openvassd"]

## TARGET: gvmd

FROM gvm-libs AS gvmd-base

RUN mkdir -pv /usr/local/share/gvm/gvmd/report_formats

RUN apt-get update && apt-get -qy install \
	libical3 \
	libsqlite3-0

FROM gvm-libs-heavy AS gvmd-heavy

RUN apt-get update && apt-get -qy install \
	libical-dev \
	libsqlite3-dev

ENV GVMD_ARCHIVE="gvmd-8.0.0.tar.gz"
ADD var/$GVMD_ARCHIVE /opt

RUN mv /opt/gvmd-* /opt/gvmd
WORKDIR /opt/gvmd
RUN cmake -D CMAKE_BUILD_TYPE=Release . && make && make install && make clean

FROM gvmd-base AS gvmd

COPY --from=gvmd-heavy /usr/local/var/lib/gvm/ /usr/local/var/lib/
COPY --from=gvmd-heavy /usr/local/etc/gvm/ /usr/local/etc/
COPY --from=gvmd-heavy /usr/local/share/gvm/ /usr/local/share/
COPY --from=gvmd-heavy /usr/local/sbin/gvm* /usr/local/sbin/greenbone-*data-sync /usr/local/sbin/
COPY --from=gvmd-heavy /usr/local/bin/gvm* /usr/local/bin/greenbone-*data-sync /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/gvmd"]

## TARGET: gsad

FROM gvm-libs AS gsa-base

RUN apt-get update && apt-get -qy install \
	libmicrohttpd12 \
	libxml2

FROM gvm-libs-heavy AS gsa-heavy

RUN curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && echo "deb https://deb.nodesource.com/node_12.x buster main" | tee /etc/apt/sources.list.d/nodesource.list && apt-get update && apt-get -qy install nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && apt-get update && apt-get -qy install yarn

RUN apt-get update && apt-get -qy install \
	libmicrohttpd-dev \
	libxml2-dev

ENV GSA_ARCHIVE="gsa-8.0.0.tar.gz"
ADD var/$GSA_ARCHIVE /opt

RUN mv /opt/gsa-* /opt/gsa
WORKDIR /opt/gsa
RUN ldconfig && cmake -DCMAKE_BUILD_TYPE=Release . && make && make install && make clean

FROM gsa-base AS gsa

VOLUME ["/usr/local/var/lib/gvm/CA/servercert.pem", "/usr/local/var/lib/gvm/private/CA/serverkey.pem"]

COPY --from=gsa-heavy /usr/local/share/gvm/gsad/ /usr/local/share/gvm/gsad/
COPY --from=gsa-heavy /usr/local/sbin/gsad /usr/local/sbin/
COPY --from=gsa-heavy /usr/local/etc/gvm/ /usr/local/etc/gvm/

ADD "./bin/gsad-wrapper.bash" "/bin/gsad"

ENTRYPOINT ["/bin/gsad"]
