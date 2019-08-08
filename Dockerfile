FROM debian:buster-slim AS base

RUN mkdir -pv /usr/local/var/run && apt-get update && apt-get -qy install \
	bzip2 \
	curl \
	file \
	heimdal-multidev \
	libglib2.0-0 \
	libgnutls30 \
	libgpgme11 \
	libhiredis0.14 \
	libksba8 \
	libldap-2.4-2 \
	libpcap0.8 \
	libpopt0 \
	libpq5 \
	libpqtypes0 \
	libradcli4 \
	libsnmp30 \
	libssh-4 \
	libssh2-1 \
	rrdtool \
	rsync \
	wget \
	&& rm -rfv /var/lib/apt/lists/*

FROM base AS build-deps

RUN apt-get update && apt-get -qy install \
	bison \
	build-essential \
	cmake \
	curl \
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
	libpq-dev \
	libpqtypes-dev \
	libradcli-dev \
	libsnmp-dev \
	libssh-dev \
	libssh2-1-dev \
	pkg-config \
	postgresql-server-dev-11 \
	&& rm -rfv /var/lib/apt/lists/*

ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig

FROM build-deps AS gvm-libs-heavy

ENV GVM_LIBS_ARCHIVE="gvm-libs--10.0.1.tar.gz"
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

## TARGET: openvas

FROM gvm-libs-heavy AS openvas-heavy

ENV OPENVAS_ARCHIVE="openvas--6.0.1.tar.gz"
ADD var/$OPENVAS_ARCHIVE /opt

RUN mv /opt/openvas-6* /opt/openvas
WORKDIR /opt/openvas
RUN cmake -D CMAKE_BUILD_TYPE=Release . && make && make install && make clean

FROM gvm-libs AS openvas

COPY --from=openvas-heavy /usr/local/lib/libopenvas*.so /usr/local/lib/
COPY --from=openvas-heavy /usr/local/var/log/gvm/ /usr/local/var/log/
COPY --from=openvas-heavy /usr/local/etc/openvas/ /usr/local/etc/
COPY --from=openvas-heavy /usr/local/sbin/greenbone* /usr/local/sbin/openvassd /usr/local/sbin/
COPY --from=openvas-heavy /usr/local/bin/openvas* /usr/local/bin/
RUN ldconfig

ENTRYPOINT ["/usr/local/sbin/openvassd", "--foreground"]

## TARGET: gvmd

FROM gvm-libs AS gvmd-base

RUN mkdir -pv /usr/local/share/gvm/gvmd/report_formats /usr/local/etc/gvm

RUN apt-get update && apt-get -qy install \
	libical3 \
	&& rm -rfv /var/lib/apt/lists/*

FROM gvm-libs-heavy AS gvmd-heavy

RUN apt-get update && apt-get -qy install \
	libical-dev \
	&& rm -rfv /var/lib/apt/lists/*

ENV GVMD_ARCHIVE="gvmd-8.0.1.tar.gz"
ADD var/$GVMD_ARCHIVE /opt

RUN mv /opt/gvmd-* /opt/gvmd
WORKDIR /opt/gvmd
RUN cmake -D BACKEND=POSTGRESQL -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql/ -D CMAKE_BUILD_TYPE=Release . -D BACKEND=POSTGRESQL && make && make install && make clean

FROM gvmd-base AS gvmd

COPY --from=gvmd-heavy /usr/local/var/lib/gvm/ /usr/local/var/lib/
COPY --from=gvmd-heavy /usr/local/etc/gvm/ /usr/local/etc/gvm/
COPY --from=gvmd-heavy /usr/local/share/gvm/ /usr/local/share/
COPY --from=openvas-heavy /usr/local/sbin/greenbone-nvt-sync /usr/local/sbin/
COPY --from=gvmd-heavy /usr/local/sbin/gvm* /usr/local/sbin/greenbone-*-sync /usr/local/sbin/
COPY --from=gvmd-heavy /usr/local/bin/gvm* /usr/local/bin/greenbone-*-sync /usr/local/bin/

ENTRYPOINT ["/usr/local/sbin/gvmd", "--foreground"]

## TARGET: gsad

FROM gvm-libs AS gsad-base

RUN apt-get update && apt-get -qy install \
	libmicrohttpd12 \
	libxml2 \
	&& rm -rfv /var/lib/apt/lists/*

FROM gvm-libs-heavy AS gsad-heavy

RUN curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && echo "deb https://deb.nodesource.com/node_12.x buster main" | tee /etc/apt/sources.list.d/nodesource.list && apt-get update && apt-get -qy install nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && apt-get update && apt-get -qy install yarn

RUN apt-get update && apt-get -qy install \
	libmicrohttpd-dev \
	libxml2-dev \
	&& rm -rfv /var/lib/apt/lists/*

ENV GSA_ARCHIVE="gsa-8.0.1.tar.gz"
ADD var/$GSA_ARCHIVE /opt

RUN mv /opt/gsa-* /opt/gsa
WORKDIR /opt/gsa
RUN ldconfig && cmake -DCMAKE_BUILD_TYPE=Release . && make && make install && make clean

FROM gsad-base AS gsad

VOLUME ["/usr/local/var/lib/gvm/CA/servercert.pem", "/usr/local/var/lib/gvm/private/CA/serverkey.pem"]

COPY --from=gsad-heavy /usr/local/share/gvm/gsad/ /usr/local/share/gvm/gsad/
COPY --from=gsad-heavy /usr/local/sbin/gsad /usr/local/sbin/
COPY --from=gsad-heavy /usr/local/etc/gvm/ /usr/local/etc/gvm/

ADD "./bin/gsad/docker-entrypoint.sh" "/usr/local/bin/"

ENTRYPOINT ["docker-entrypoint.sh"]

# TODO this needs to be something else---maybe just a cron base?
FROM alpine:latest AS sync

RUN apk add -U rsync && rm -v /var/spool/cron/crontabs/root

VOLUME /var/spool/cron/crontabs/root

COPY --from=openvas-heavy /usr/local/sbin/greenbone-nvt-sync /sbin/
COPY --from=gvmd-heavy /usr/local/sbin/greenbone-*-sync /sbin/

CMD crond -f -l 8
