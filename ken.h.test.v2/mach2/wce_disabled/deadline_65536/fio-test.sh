#!/bin/sh
set -e


rm -f *.map *.log
source ./lvm_funcs.sh

#DISK_READ_AHEAD=4096
#DISK_READ_AHEAD=32768
DISK_READ_AHEAD=65536
#DISK_READ_AHEAD=131072
DISK_SCHEDULER='deadline'
#DISK_SCHEDULER='noop'

do_fio_test() {
	TDIR=$1
	MYTGT=$2
	TNAME=$3
	if [[ ! -d $TDIR ]]; then
		mkdir -p "$TDIR"
	fi
	cd $TDIR
	JOBS=1
	for PAT in 'read' 'write' 'randrw' 'randread' 'randwrite'; do
		for BLK in 4k 8k 16k 32k 128k 256k 512k 1024k 2048k 4096k; do
			for QUE in 1 4 8 16 32 64 128 256 512 1024; do
				echo "running $PAT with $BLK and iodepth=$QUE fio against $MYTGT"
				fio --filename=$MYTGT \
				    --rw=$PAT \
				    --ioengine=libaio \
				    --iodepth=$QUE \
				    --numjobs=$JOBS \
				    --direct=1 \
				    --runtime=120 \
				    --name="$PAT-$BLK" \
				    --group_reporting  \
				    --bs=$BLK \
				    --output-format=json | tee  "$TNAME-$PAT-$BLK-$QUE-$JOBS.fio.json"
			done
		done
	done
}

mk_lvms | tee test.log
for DTYPE in mach2 evans
do
	TDIR="${DTYPE}/${DISK_SCHEDULER}_${DISK_READ_AHEAD}"
	while read TGT
	do
		TNAME=$(basename $TGT)
		do_fio_test $TDIR $TGT $TNAME &	
	done <LVM_${DTYPE}.map
done

