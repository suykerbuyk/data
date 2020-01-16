#!/bin/sh
TGT='/dev/rbd0'
OUTDIR="krbd-tune"
PREFIX="krbd-$(hostname)"
for JCNT in 1 4 8 12 16 24; do
	for PAT in 'read' 'write' 'randrw' 'randread' 'randwrite'; do
		for BLK in 4k 8k 16k 32k 64k 128k 256k 1m 2m; do
			echo 'rbd create rbd/fiorbd --size=400G'
			rbd create rbd/fiorbd --size=400G
			echo 'rbd map rbd/fiorbd'
			rbd map rbd/fiorbd
			JCNTSTR=$(printf J%02d $JCNT)
			echo "running $PAT with $BLK and job count $JCNT fio against $TGT"
			OUTFILE="$OUTDIR/$PREFIX-$JCNTSTR-$PAT-$BLK.fio.json"
                        echo "Output = $OUTFILE"
			fio --filename=$TGT \
			    --rw=$PAT \
			    --ioengine=libaio \
			    --iodepth=16 \
			    --numjobs=$JCNT \
			    --runtime=120 \
			    --name="$PAT-$BLK" \
			    --group_reporting  \
			    --bs=$BLK \
			    --output-format=json | tee $OUTFILE
			echo 'rbd unmap /dev/rbd0'
			rbd unmap /dev/rbd0
			echo 'rbd rm rbd/fiorbd'
			rbd rm rbd/fiorbd
 		done
	done
done
