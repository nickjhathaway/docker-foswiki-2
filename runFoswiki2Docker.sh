#!/bin/bash

# this assumes ""${NAME}"" is disposable!
# runs ${IMAGE} with external file systems mounted in.

export IMAGE="foswiki2"
export NAME="foswiki2"
export BASE="/data/docker/foswiki2"


if [ "X$1" != "Xyes" ]; then
	echo
	echo "--------------------------------------------------------------------"
	echo "This script destroys existing container with name \"${NAME}\" and"
	echo "starts a new instance based on ${IMAGE}."
	echo
	echo "Run as '$0 yes' if this is what you intend to do."
	echo "--------------------------------------------------------------------"
	echo
	exit 0
fi

docker stop "${NAME}"
docker rm "${NAME}"

docker run \
	-v "${BASE}/var/www/html/Foswiki-2.0.0:/var/www/html/Foswiki-2.0.0" \
	-v "${BASE}/var/log:/var/log" \
	-P -p 127.0.0.1:8080:80 \
	-d --restart=always \
	--hostname="${NAME}" --name="${NAME}" "${IMAGE}"
	
	
