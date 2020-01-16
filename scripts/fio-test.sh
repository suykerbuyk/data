#!/bin/sh

TGT='/dev/md/MD-001-sdo-sdp'
PAT=randrw
for PAT in 'read' 'write' 'randrw' 'randread' 'randwrite'; do
	for BLK in 4k 8k 16k 32k 512k 1M 2M; do
		echo "running $PAT with $BLK fio against $TGT"
		fio --filename=$TGT \
		    --rw=$PAT \
		    --ioengine=libaio \
		    --iodepth=16 \
		    --numjobs=$JOBS \
		    --runtime=120 \
		    --name="$PAT-$BLK" \
		    --group_reporting  \
		    --bs=$BLK \
		    --output-format=json | tee  "$PAT-$BLK.fio.json"
	done
done
