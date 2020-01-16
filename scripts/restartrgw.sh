#!/bin/bash
for i in 6 7 8
do
	echo Restarting RGW on lr02u2$i
	ssh lr02u2${i} systemctl restart ceph-radosgw@rgw.lr02u2${i}
done
