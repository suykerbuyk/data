#!/bin/sh
zpool destroy tank
for x in $(ls /dev/disk/by-id/ | grep wwn-0x6000 | grep 0001000000000000 | grep -v part) 
do
	echo $x
	parted /dev/disk/by-id/$x rm 1 rm 9
done
parted /dev/disk/by-id/wwn-0x5000c500302dc95b rm 1 rm 9
parted /dev/disk/by-id/wwn-0x5000c500302d4333 rm 1 rm 9
