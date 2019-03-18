# STEP 1: Install build deps and the like.
FROM centos:7 AS centos-epel-build

RUN yum install -y epel-release
RUN yum install -y \
	bison \
	cmake \
	curl \
	doxygen \
	file \
	gcc-c++ \
	gcc \
	git \
	glib2-devel \
	glibc-devel \
	gnutls-devel \
	gpgme-devel \
	hiredis-devel \
	libgcrypt-devel \
	libgpg-error-devel \
	libksba-devel \
	libpcap-devel \
	libssh \
	libssh-devel \
	libuuid-devel \
	make \
	net-snmp-agent-libs \
	net-snmp-devel \
	net-snmp-libs \
	net-snmp-utils \
	openldap-devel \
	pkgconfig \
	sqlite-devel \
	wget \
	zlib-devel

# STEP 2: Install libgcrypt and libgpg-error
FROM centos-epel-build AS gcrypt

ENV GPG_ERROR_ARCHIVE="libgpg-error-1.35.tar.gz"
ENV GCRYPT_ARCHIVE="libgcrypt-1.8.4.tar.gz"

ADD ./var/$GPG_ERROR_ARCHIVE /tmp/

RUN mv /tmp/libgpg-error-* /tmp/libgpg-error
WORKDIR /tmp/libgpg-error
RUN ./configure; make; make install

ADD ./var/$GCRYPT_ARCHIVE /tmp/

RUN mv /tmp/libgcrypt-* /tmp/libgcrypt
WORKDIR /tmp/libgcrypt
RUN ./configure; make; make install

# STEP 3: Build CMake from source (latest available on CentOS is 2.18, too out of date)
FROM gcrypt AS cmake

ENV CMAKE_ARCHIVE="cmake-3.14.0.tar.gz"
ADD var/$CMAKE_ARCHIVE /opt

RUN mv /opt/cmake-* /opt/cmake
WORKDIR /opt/cmake
RUN ./bootstrap --prefix=/usr/local; make; make install

ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig

# STEP 4: Build gvm-libs from source
FROM cmake AS gvm-libs

ENV GVM_LIBS_ARCHIVE="gvm-libs--9.0.3.tar.gz"
ADD var/$GVM_LIBS_ARCHIVE /opt

RUN mv /opt/gvm-libs-* /opt/gvm-libs
WORKDIR /opt/gvm-libs
RUN cmake .; make; make install

# STEP 5: Build openvas-scanner from source
FROM gvm-libs AS openvas-scanner

ENV OPENVAS_SCANNER_ARCHIVE="openvas-scanner--5.1.3.tar.gz"
ADD var/$OPENVAS_SCANNER_ARCHIVE /opt

RUN mv /opt/openvas-scanner-* /opt/openvas-scanner
WORKDIR /opt/openvas-scanner
RUN cmake .; make; make install

# STEP 6: Build gvmd from source
FROM openvas-scanner AS gvmd

ENV GVMD_ARCHIVE="gvmd-7.0.3.tar.gz"
ADD var/$GVMD_ARCHIVE /opt

RUN mv /opt/gvmd-* /opt/gvmd
WORKDIR /opt/gvmd
RUN cmake .; make; make install

# STEP 7: Build gsa from source
FROM gvmd AS gsa

ENV GSA_ARCHIVE="gsa-7.0.3.tar.gz"
ADD var/$GSA_ARCHIVE /opt

RUN mv /opt/gsa-* /opt/gsa
WORKDIR /opt/gsa
RUN cmake .; make; make install
