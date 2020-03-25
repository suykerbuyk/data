#!/bin/sh

TGT='/dev/sgt_vg_data_000/sgt_lv_data_000'
PAT=randrw
JOBS=1
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
