#!/bin/sh

for tag in base sync openvas gvmd gsad;
do
	docker image save "openvas-docker/${tag}" > "${tag}.tar"
done
