# lopenvas

>What even is that name?

Good question.

## Introduction

`lopenvas` is a dockerized OpenVAS installation that aims to be as slim as possible.
Using multi-stage builds, we try to avoid including cruft in the final Docker images, and we also try to separate the components of the system as much as possible while still preserving functionality.

Support for versions other than the latest is out-of-scope, however migratory functionality will hopefully be preserved between releases with minimal effort.

## Local development

To hack on this locally, you'll need to first run the `./pre_warm.sh` file at the root of the project.
This downloads the release artifacts from GitHub so that the Docker build properly has them.

## License

The `lopenvas`-related source code (which is found in this repository and consists primarily of build and deployment scripts) is written by me, however the actual OpenVAS/GSA/GVM source code is the intellectual property of Greenbone Networks, GmbH.
The built images contain this source code, and hence are subject to the license for the Greenbone-copyrighted software.
