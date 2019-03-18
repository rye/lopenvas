# openvas

This repository contains a build of the OpenVAS/GVM project.  It is intended to
be deployed on the St. Olaf network.

## Setup

First, run `./pre_warm.sh` which can be found at the root of the project.
Ensure that the `SHA256SUMS` are all listed as `OK`!  (You will need the `wget`
and `sha256sum` commands to get there.)

Then, all you need is `docker build` and you're (hopefully) off to the races!
