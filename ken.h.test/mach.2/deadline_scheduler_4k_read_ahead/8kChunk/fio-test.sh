#!/bin/sh

TGT='/dev/disk/by-id/dm-name-sgt_vg_data_004-sgt_lv_data_004'
JOBS=1
for PAT in 'read' 'write' 'randrw' 'randread' 'randwrite'; do
	for BLK in 4k 8k 16k 32k 128k 256k 512k 1024k 2048k 4096k; do
		for QUE in 1 4 8 16 32 64 128 256 512 1024; do
			echo "running $PAT with $BLK and iodepth=$QUE fio against $TGT"
			fio --filename=$TGT \
			    --rw=$PAT \
			    --ioengine=libaio \
			    --iodepth=$QUE \
			    --numjobs=$JOBS \
			    --direct=1 \
			    --runtime=120 \
			    --name="$PAT-$BLK" \
			    --group_reporting  \
			    --bs=$BLK \
			    --output-format=json | tee  "$PAT-$BLK-$QUE.fio.json"
		done
	done
done
