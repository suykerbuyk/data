#!/bin/sh

set -e

for MDDEV in $( ls /dev/md/ | grep MD)
do 
	echo "mdadm --stop /dev/md/$MDDEV"
	mdadm --stop /dev/md/$MDDEV
done
for DEV in $( ls /dev/disk/by-path/ | \
              grep -v 'phy' | grep 'lun-1' | \
              sort | rev | cut -c 7- | rev ); do
        dev1="/dev/disk/by-path/$DEV-lun-0"
        dev2="/dev/disk/by-path/$DEV-lun-1"
        #kdev1="$(ls -lah $dev1 | awk -F '/' '{print $7}')"
        #kdev2="$(ls -lah $dev2 | awk -F '/' '{print $7}')"
	echo "mdadm --zero-superblock $dev1"
	mdadm --zero-superblock $dev1
	mdadm --zero-superblock $dev2
done


