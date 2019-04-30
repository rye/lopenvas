# STEP 1: Install build deps and the like.
FROM debian:buster-slim AS build-deps

RUN apt-get update && apt-get -qy install \
	bison \
	build-essential \
	cmake \
	curl \
	doxygen \
	file \
	git \
	glibc-source \
	libgcrypt-dev \
	libglib2.0-dev \
	libgpg-error-dev \
	libgnutls28-dev \
	libgpgme-dev \
	libhiredis-dev \
	libical-dev \
	libksba-dev \
	libldap2-dev \
	libmicrohttpd-dev \
	libpcap-dev \
	libsnmp-base \
	libsnmp-dev \
	libssh-dev \
	libssh2-1-dev \
	libsqlite3-dev \
	libuuid1 \
	libxml2-dev \
	libxslt-dev \
	snmp \
	pkg-config \
	wget \
	zlib1g-dev

#RUN echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf
#RUN echo "/usr/local/lib64" >> /etc/ld.so.conf.d/local-64.conf
ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig

# STEP 2: Build gvm-libs from source
FROM build-deps AS gvm-libs

ENV GVM_LIBS_ARCHIVE="gvm-libs--10.0.0.tar.gz"
ADD var/$GVM_LIBS_ARCHIVE /opt

RUN mv /opt/gvm-libs-* /opt/gvm-libs
WORKDIR /opt/gvm-libs
RUN cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_C_FLAGS=-Wno-deprecations .; make; make install; make clean

# STEP 3: Build openvas-scanner from source
FROM gvm-libs AS openvas-scanner

ENV OPENVAS_SCANNER_ARCHIVE="openvas-scanner--6.0.0.tar.gz"
ADD var/$OPENVAS_SCANNER_ARCHIVE /opt

RUN mv /opt/openvas-scanner-* /opt/openvas-scanner
WORKDIR /opt/openvas-scanner
RUN cmake -D CMAKE_BUILD_TYPE=Release .; make; make install; make clean

# STEP 4: Build gvmd from source
FROM gvm-libs AS gvmd

ENV GVMD_ARCHIVE="gvmd-8.0.0.tar.gz"
ADD var/$GVMD_ARCHIVE /opt

RUN mv /opt/gvmd-* /opt/gvmd
WORKDIR /opt/gvmd
RUN cmake -D CMAKE_BUILD_TYPE=Release .; make; make install; make clean

# STEP 5: Build gsa from source
FROM gvm-libs AS gsa

RUN curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -; echo "deb https://deb.nodesource.com/node_12.x buster main" | tee /etc/apt/sources.list.d/nodesource.list; apt-get update; apt-get -qy install nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list; apt-get update; apt-get -qy install yarn

ENV GSA_ARCHIVE="gsa-8.0.0.tar.gz"
ADD var/$GSA_ARCHIVE /opt

RUN mv /opt/gsa-* /opt/gsa
WORKDIR /opt/gsa
RUN ldconfig; cmake -DCMAKE_BUILD_TYPE=Release .; make; make install; make clean

# STEP 8: Build openvas-smb from sourcen
#FROM gsa as openvas-smb

#ENV OPENVAS_SMB_ARCHIVE="openvas-smb--1.0.4.tar.gz"
#ADD var/$OPENVAS_SMB_ARCHIVE /opt

#RUN mv /opt/openvas-smb-* /opt/openvas-smb
#WORKDIR /opt/openvas-smb
#RUN cmake .; make; make install
