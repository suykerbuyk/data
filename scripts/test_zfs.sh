#!/bin/sh

set -e

POOL=tank

rm_zfs_parts() {
	if [ $(grep -qs "$POOL" /proc/mounts) ]; then
		echo "$POOL is NOT mounted"
	else
		echo "$POOL is mounted"
		zpool destroy $POOL
	fi
	for x in $(ls /dev/disk/by-id/ | grep wwn-0x6000 | grep 0001000000000000 | grep -v part) 
	do
		LUN1="/dev/disk/by-id/$x"
		LUN0="$(echo $LUN1 | sed 's/0001000000000000/0000000000000000/g')"
		for DISK in $LUN0 $LUN1
		do
			for PART in $(fdisk -l $DISK 2>/dev/null | grep Solaris | sort -r | awk '{print $1}')
			do 
				# echo "parted $DISK rm $PART"
				parted -s $DISK rm $PART
			done
		done
		#echo "parted $LUN1 rm 1 rm 9"
	done
}

harrier_zfs_raid1() {
zpool create $POOL \
	raidz1 wwn-0x6000c500ae17766b0001000000000000 \
	       wwn-0x6000c500ae1809070001000000000000 \
	       wwn-0x6000c500ae2efe4f0001000000000000 \
	raidz1 wwn-0x6000c500ae33c6770001000000000000 \
	       wwn-0x6000c500ae33f04f0001000000000000 \
	       wwn-0x6000c500ae3556070001000000000000 \
	raidz1 wwn-0x6000c500ae3597a30001000000000000 \
	       wwn-0x6000c500ae35dcff0001000000000000 \
	       wwn-0x6000c500ae35e00b0001000000000000 \
	raidz1 wwn-0x6000c500ae35feeb0001000000000000 \
	       wwn-0x6000c500ae3635630001000000000000 \
	       wwn-0x6000c500ae3640bb0001000000000000 \
	raidz1 wwn-0x6000c500ae17766b0000000000000000 \
	       wwn-0x6000c500ae1809070000000000000000 \
	       wwn-0x6000c500ae2efe4f0000000000000000 \
	raidz1 wwn-0x6000c500ae33c6770000000000000000 \
	       wwn-0x6000c500ae33f04f0000000000000000 \
	       wwn-0x6000c500ae3556070000000000000000 \
	raidz1 wwn-0x6000c500ae3597a30000000000000000 \
	       wwn-0x6000c500ae35dcff0000000000000000 \
	       wwn-0x6000c500ae35e00b0000000000000000 \
	raidz1 wwn-0x6000c500ae35feeb0000000000000000 \
	       wwn-0x6000c500ae3635630000000000000000 \
	       wwn-0x6000c500ae3640bb0000000000000000 \
	       -o feature@lz4_compress=disabled
}

harrier_zfs_raid2() {
	zpool create $POOL \
	raidz2 wwn-0x6000c500ae17766b0001000000000000 \
	       wwn-0x6000c500ae1809070001000000000000 \
	       wwn-0x6000c500ae2efe4f0001000000000000 \
	       wwn-0x6000c500ae33c6770001000000000000 \
	raidz2 wwn-0x6000c500ae33f04f0001000000000000 \
	       wwn-0x6000c500ae3556070001000000000000 \
	       wwn-0x6000c500ae3597a30001000000000000 \
	       wwn-0x6000c500ae35dcff0001000000000000 \
	raidz2 wwn-0x6000c500ae35e00b0001000000000000 \
	       wwn-0x6000c500ae35feeb0001000000000000 \
	       wwn-0x6000c500ae3635630001000000000000 \
	       wwn-0x6000c500ae3640bb0001000000000000 \
	raidz2 wwn-0x6000c500ae17766b0000000000000000 \
	       wwn-0x6000c500ae1809070000000000000000 \
	       wwn-0x6000c500ae2efe4f0000000000000000 \
	       wwn-0x6000c500ae33c6770000000000000000 \
	raidz2 wwn-0x6000c500ae33f04f0000000000000000 \
	       wwn-0x6000c500ae3556070000000000000000 \
	       wwn-0x6000c500ae3597a30000000000000000 \
	       wwn-0x6000c500ae35dcff0000000000000000 \
	raidz2 wwn-0x6000c500ae35e00b0000000000000000 \
	       wwn-0x6000c500ae35feeb0000000000000000 \
	       wwn-0x6000c500ae3635630000000000000000 \
	       wwn-0x6000c500ae3640bb0000000000000000 \
	       -o feature@lz4_compress=disabled
}

harrier_zfs_mirror() {
	zpool create tank \
	mirror wwn-0x6000c500ae17766b0001000000000000 \
	       wwn-0x6000c500ae1809070001000000000000 \
	mirror wwn-0x6000c500ae2efe4f0001000000000000 \
	       wwn-0x6000c500ae33c6770001000000000000 \
	mirror wwn-0x6000c500ae33f04f0001000000000000 \
	       wwn-0x6000c500ae3556070001000000000000 \
	mirror wwn-0x6000c500ae3597a30001000000000000 \
	       wwn-0x6000c500ae35dcff0001000000000000 \
	mirror wwn-0x6000c500ae35e00b0001000000000000 \
	       wwn-0x6000c500ae35feeb0001000000000000 \
	mirror wwn-0x6000c500ae3635630001000000000000 \
	       wwn-0x6000c500ae3640bb0001000000000000 \
	mirror wwn-0x6000c500ae17766b0000000000000000 \
	       wwn-0x6000c500ae1809070000000000000000 \
	mirror wwn-0x6000c500ae2efe4f0000000000000000 \
	       wwn-0x6000c500ae33c6770000000000000000 \
	mirror wwn-0x6000c500ae33f04f0000000000000000 \
	       wwn-0x6000c500ae3556070000000000000000 \
	mirror wwn-0x6000c500ae3597a30000000000000000 \
	       wwn-0x6000c500ae35dcff0000000000000000 \
	mirror wwn-0x6000c500ae35e00b0000000000000000 \
	       wwn-0x6000c500ae35feeb0000000000000000 \
	mirror wwn-0x6000c500ae3635630000000000000000 \
	       wwn-0x6000c500ae3640bb0000000000000000 \
	       -o feature@lz4_compress=disabled
}

# cache  wwn-0x5000c500302dc95b \
# log    wwn-0x5000c500302d4333
if [ ! -d log ]; then
	mkdir log
fi
for config in 'harrier_zfs_raid1' 'harrier_zfs_raid2' 'harrier_zfs_mirror' 
do
	rm_zfs_parts
	$config
	for JOBS in 1 4 8 16 32; do
		for PAT in 'read' 'write' 'randrw' 'randread' 'randwrite'; do
		        for BLK in 4k 8k 16k 32k 512k 1M 2M; do
		                echo "running $PAT with $BLK fio against $POOL"
				# fio --name="${config}-$PAT-$BLK" \
				fio --directory=/$POOL/ \
				    --rw=$PAT \
				    --group_reporting=1 \
				    --bs=$BLK \
				    --direct=1 \
				    --numjobs=$JOBS \
				    --time_based=1 \
				    --runtime=180 \
				    --iodepth=128 \
				    --ioengine=libaio \
				    --name=file01 --size=8G --filename=file.01.fio \
				    --name=file02 --size=8G --filename=file.02.fio \
				    --name=file03 --size=8G --filename=file.03.fio \
				    --name=file04 --size=8G --filename=file.04.fio \
				    --name=file05 --size=8G --filename=file.05.fio \
				    --name=file06 --size=8G --filename=file.06.fio \
				    --name=file07 --size=8G --filename=file.07.fio \
				    --name=file08 --size=8G --filename=file.08.fio \
				    --name=file09 --size=8G --filename=file.09.fio \
				    --name=file10 --size=8G --filename=file.10.fio \
				    --name=file11 --size=8G --filename=file.11.fio \
				    --name=file12 --size=8G --filename=file.12.fio \
				    --name=file13 --size=8G --filename=file.13.fio \
				    --name=file14 --size=8G --filename=file.14.fio \
				    --name=file15 --size=8G --filename=file.15.fio \
				    --name=file16 --size=8G --filename=file.16.fio \
				    --name=file17 --size=8G --filename=file.17.fio \
				    --name=file18 --size=8G --filename=file.18.fio \
				    --name=file19 --size=8G --filename=file.19.fio \
				    --name=file20 --size=8G --filename=file.20.fio \
				    --name=file21 --size=8G --filename=file.21.fio \
				    --name=file22 --size=8G --filename=file.22.fio \
				    --name=file23 --size=8G --filename=file.23.fio \
				    --name=file24 --size=8G --filename=file.24.fio \
				    --name=file25 --size=8G --filename=file.25.fio \
				    --name=file26 --size=8G --filename=file.26.fio \
				    --name=file27 --size=8G --filename=file.27.fio \
				    --name=file28 --size=8G --filename=file.28.fio \
				    --name=file29 --size=8G --filename=file.29.fio \
				    --name=file30 --size=8G --filename=file.30.fio \
				    --name=file31 --size=8G --filename=file.31.fio \
				    --name=file32 --size=8G --filename=file.32.fio \
		                    --output-format=json | tee "$PWD/log/${config}-$PAT-$BLK-$JOBS.fio.json"
				echo "Completed"
		        done
		done
	done
done

 # fio fio/saturate.fio | tee log/saturate-zfs1-no-cache-8files-bs128k.log
 # fio fio/saturate.fio | tee log/saturate-zfs2-no-cache-8files-bs128k.log
 # fio fio/saturate.fio | tee log/saturate-zfs.mirror-no-cache-8files-bs128k.log

