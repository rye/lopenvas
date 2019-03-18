# STEP 1: Install build deps and the like.
FROM centos:7 AS centos-epel-build

RUN yum install -y epel-release

# STEP 2: Install libgcrypt and libgpg-error
FROM centos-epel-build AS gcrypt

# STEP 2: Build CMake from source (latest available on CentOS is 2.18, too out of date)
FROM gcrypt AS cmake

# STEP 3: Build gvm-libs from source
FROM cmake AS gvm-libs

# STEP 4: Build openvas-scanner from source
FROM gvm-libs AS openvas-scanner

# STEP 5: Build gvmd from source
FROM openvas-scanner AS gvmd

# STEP 6: Build gsa from source
FROM gvmd AS gsa
