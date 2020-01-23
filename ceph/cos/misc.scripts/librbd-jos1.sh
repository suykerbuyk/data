#!/bin/sh
#ceph osd pool create rbd 1024
#rbd pool init rbd
rbd create rbd/fiorbd --size=200G

TGT='/librbd0'
JOBS=1
OUTDIR="librbd-tune"
PREFIX="librbd-$(hostname)"
for JCNT in 1 4 8 12 16 24; do
	for PAT in 'read' 'write' 'randrw' 'randread' 'randwrite'; do
		for BLK in 4k 8k 16k 32k 64k 128k 256k 1m 2m; do
			echo 'rbd create rbd/fiorbd --size=400G'
			rbd create rbd/fiorbd --size=400G
			JCNTSTR=$(printf J%02d $JCNT)
			echo "running $PAT with $BLK and job count $JCNT fio against $TGT"
			OUTFILE="$OUTDIR/$PREFIX-$JCNTSTR-$PAT-$BLK.fio.json"
                        echo "Output = $OUTFILE"
			fio --filename=$TGT \
			    --rw=$PAT \
			    --ioengine=rbd \
			    --clientname=admin \
			    --pool=rbd \
			    --rbdname=fiorbd \
			    --iodepth=16 \
			    --numjobs=$JCNT \
			    --runtime=120 \
			    --name="$PAT-$BLK" \
			    --group_reporting  \
			    --bs=$BLK \
			    --output-format=json | tee $OUTFILE
			echo "rbd rm rbd/fiorbd"
			rbd rm rbd/fiorbd
 		done
	done
done
