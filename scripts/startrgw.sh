#!/bin/bash
for i in 6 7 8
do
	echo Staring RGW on lr02u2$i
	ssh lr02u2${i} systemctl start ceph-radosgw@rgw.lr02u2${i}
done
