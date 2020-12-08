#!/bin/bash

set -e -x

URL_BASE="quay.io/pypa/"
PLATFORMS="manylinux2010_x86_64 manylinux2010_i686"

# Go back to root dir
cd ../../

for PLAT in ${PLATFORMS}
do
	DOCKER_IMAGE="${URL_BASE}${PLAT}"
	docker pull "${DOCKER_IMAGE}"
	docker container run -t --rm \
		-e PLAT=$PLAT \
		-v "$(pwd)":/io \
		--workdir /io \
		"${DOCKER_IMAGE}" /io/python/pypi/build_manylinux_wheels_sub.sh
done

# To enter the container in interactive bash shell use something like the following:
# docker container run -it --rm -e PLAT=manylinux1_x86_64 -v "$(dirname pwd)":/io -w /io quay.io/pypa/manylinux1_x86_64 /bin/bash
