#!/bin/sh

set -e

for y in $(seq 0 16)
do
	for x in $(seq 0 16)
	do
		TGT=$(printf "%03d_%03d" $y $x)
		FILE=$(echo "/tank/FILLER_$TGT.tmp")
		echo "dd if=/dev/zero of=$FILE oflag=sync"
		dd if=/dev/zero of=$FILE bs=1G count=100 oflag=sync &
	done
	wait
done
