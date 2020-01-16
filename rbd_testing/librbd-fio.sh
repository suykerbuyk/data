#!/bin/sh
#ceph osd pool create rbd 1024
#rbd pool init rbd
rbd create rbd/fiorbd --size=100G

TGT='/librbd0'
PAT=randrw
JOBS=1
for PAT in 'read' 'write' 'randrw' 'randread' 'randwrite'; do
        for BLK in 4k 8k 16k 32k 512k 1M 2M; do
                echo "running $PAT with $BLK fio against $TGT"
                fio --filename=$TGT \
                    --rw=$PAT \
                    --ioengine=rbd \
                    --clientname=admin \
                    --pool=rbd \
                    --rbdname=fiorbd \
                    --iodepth=16 \
                    --numjobs=$JOBS \
                    --runtime=120 \
                    --name="$PAT-$BLK" \
                    --group_reporting  \
                    --bs=$BLK \
                    --output-format=json | tee  "librbd-$PAT-$BLK.fio.json"
        done
done
rbd rm rbd/fiorbd

