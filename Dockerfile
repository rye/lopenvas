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
	hiredis-devel \
	libmicrohttpd-devel \
	libpcap-devel \
	libssh \
	libssh-devel \
	libuuid-devel \
	libxml2-devel \
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

ENV ASSUAN_ARCHIVE="libassuan-2.5.3.tar.bz2"
ENV GCRYPT_ARCHIVE="libgcrypt-1.8.4.tar.gz"
ENV GNUPG_ARCHIVE="gnupg-2.2.13.tar.bz2"
ENV GPG_ERROR_ARCHIVE="libgpg-error-1.35.tar.gz"
ENV GPGME_ARCHIVE="gpgme-1.12.0.tar.bz2"
ENV KSBA_ARCHIVE="libksba-1.3.5.tar.bz2"
ENV NPTH_ARCHIVE="npth-1.6.tar.bz2"
ENV NTBTLS_ARCHIVE="ntbtls-0.1.2.tar.bz2"

RUN echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf
RUN echo "/usr/local/lib64" >> /etc/ld.so.conf.d/local-64.conf

ADD var/$GPG_ERROR_ARCHIVE /tmp/
RUN mv /tmp/libgpg-error-* /tmp/libgpg-error
WORKDIR /tmp/libgpg-error
RUN ./configure; make; make install

ADD var/$ASSUAN_ARCHIVE /tmp/
RUN mv /tmp/libassuan-* /tmp/libassuan
WORKDIR /tmp/libassuan
RUN ./configure; make; make install

ADD var/$GCRYPT_ARCHIVE /tmp/
RUN mv /tmp/libgcrypt-* /tmp/libgcrypt
WORKDIR /tmp/libgcrypt
RUN ./configure; make; make install

ADD var/$KSBA_ARCHIVE /tmp/
RUN mv /tmp/libksba-* /tmp/libksba
WORKDIR /tmp/libksba
RUN ./configure; make; make install

ADD var/$NPTH_ARCHIVE /tmp/
RUN mv /tmp/npth-* /tmp/npth
WORKDIR /tmp/npth
RUN ./configure; make; make install

ADD var/$NTBTLS_ARCHIVE /tmp/
RUN mv /tmp/ntbtls-* /tmp/ntbtls
WORKDIR /tmp/ntbtls
RUN ./configure; make; make install

ADD var/$GNUPG_ARCHIVE /tmp/
RUN mv /tmp/gnupg-* /tmp/gnupg
WORKDIR /tmp/gnupg
RUN ./configure; make; make install

ADD var/$GPGME_ARCHIVE /tmp/
RUN mv /tmp/gpgme-* /tmp/gpgme
WORKDIR /tmp/gpgme
RUN ldconfig -v; ./configure; make; make install

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

ENV XSLT_ARCHIVE="libxslt-1.1.33.tar.gz"
ADD var/$XSLT_ARCHIVE /opt

RUN mv /opt/libxslt-* /opt/libxslt
WORKDIR /opt/libxslt
RUN ./configure; make; make install

ENV GSA_ARCHIVE="gsa-7.0.3.tar.gz"
ADD var/$GSA_ARCHIVE /opt

RUN mv /opt/gsa-* /opt/gsa
WORKDIR /opt/gsa
RUN ldconfig -v; cmake .; make; make install

# STEP 8: Build openvas-smb from sourcen
#FROM gsa as openvas-smb

#ENV OPENVAS_SMB_ARCHIVE="openvas-smb--1.0.4.tar.gz"
#ADD var/$OPENVAS_SMB_ARCHIVE /opt

#RUN mv /opt/openvas-smb-* /opt/openvas-smb
#WORKDIR /opt/openvas-smb
#RUN cmake .; make; make install
