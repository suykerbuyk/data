#!/bin/sh
set -e
POOL=tank
rm_zfs_parts() {
        grep -qs "$POOL" /proc/mounts \
          && echo "Destroying previous pool \"$POOL\"" \
          && zpool destroy $POOL 
	for x in $(ls /dev/disk/by-id/ | grep wwn-0x6000 | grep 0001000000000000 | grep -v part) 
	do
		LUN1="/dev/disk/by-id/$x"
		LUN0="$(echo $LUN1 | sed 's/0001000000000000/0000000000000000/g')"
		for DISK in $LUN0 $LUN1
		do
			for PART in $(fdisk -l $DISK 2>/dev/null | grep Solaris | sort -r | awk '{print $1}')
			do 
				# echo "parted $DISK rm $PART"
				parted -s $DISK rm $PART
			done
		done
		#echo "parted $LUN1 rm 1 rm 9"
	done
}
rm_zfs_parts
