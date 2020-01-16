#!/bin/bash
for i in 6 7 8
do
	echo Stopping RGW on lr02u2$i
	ssh lr02u2${i} systemctl stop ceph-radosgw@rgw.lr02u2${i}
done
