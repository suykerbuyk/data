#!/bin/sh
#Run this command to remove RGW config and replace it with an rbd pool
./stoprgw.sh
for p in $(ceph osd pool ls)
do
    ceph osd pool delete $p $p --yes-i-really-really-mean-it
done
ceph osd pool create rbd 2048
rbd pool init rbd



