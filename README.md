# openvas

This repository contains a build of the OpenVAS/GVM project.  It is intended to
be deployed on any network which would benefit from it and that has Docker.

## Setup

First, run `./pre_warm.sh` which can be found at the root of the project.
Ensure that the `SHA256SUMS` are all listed as `OK`!  (You will need the `wget`
and `sha256sum` commands to get there.)

Then, all you need is `docker build` and you're (hopefully) off to the races!

### Why pre-warm?

We download a lot of .tar.gz archives, and doing this repetitively is bad
practice.  This allows for some semblance of a reproducible build, and gives
massive speed benefits after the first run.
