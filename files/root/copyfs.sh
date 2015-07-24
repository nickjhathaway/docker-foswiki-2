#!/bin/bash

# this is meant to be run ONCE right after initial setup
# to copy out some stuff to external filesystems

# docker run -ti --rm -v /data/docker/foswiki2:/mnt myimageid /root/copyfs.sh

# stop services 

service apache2 stop


# assume external mounts at /mnt!
tar cf - /var/log  /var/www/html/Foswiki-2.0.0 | \
	tar -C /mnt -xvf -