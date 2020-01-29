#!/bin/sh

set -e

QUIET='--quiet'
# QUIET=''

rm_mdraid() {
	echo "Stopping previous mdraid devices"
	for MDDEV in $( ls /dev/md/ | grep MD)
	do 
		mdadm --stop /dev/md/$MDDEV ${QUIET}
	done
	echo "Clearing previous mdraid devices"
	for DEV in $( ls /dev/disk/by-path/ | \
		      grep -v 'phy' | grep 'lun-1' | \
		      sort | rev | cut -c 7- | rev ); do
		dev1="/dev/disk/by-path/$DEV-lun-0"
		dev2="/dev/disk/by-path/$DEV-lun-1"
		#kdev1="$(ls -lah $dev1 | awk -F '/' '{print $7}')"
		#kdev2="$(ls -lah $dev2 | awk -F '/' '{print $7}')"
		mdadm --zero-superblock $dev1 ${QUIET}
		mdadm --zero-superblock $dev2 ${QUIET}
		wipefs -a ${dev1}
		wipefs -a ${dev2}
	done
	partprobe
}

RAID_CHUNK=4
RAID_LEVEL=0
RAID_DEVCNT=2
mk_mdraid(){
	IDX=0
	echo "Building mdraid devices"
	for DEV in $( ls /dev/disk/by-path/ | \
		      grep -v 'phy' | grep 'lun-1' | \
		      sort | rev | cut -c 7- | rev ); do
		IDX=$( expr $IDX + 1 )
		#echo "DEV $IDX"
		dev1="/dev/disk/by-path/$DEV-lun-0"
		dev2="/dev/disk/by-path/$DEV-lun-1"
		#ls -lah $dev1
		#ls -lah $dev2
		kdev1="$(ls -lah $dev1 | awk -F '/' '{print $7}')"
		kdev2="$(ls -lah $dev2 | awk -F '/' '{print $7}')"
		IDX_STR=$(printf "%03d" $IDX)
		MDNAME="MD-$IDX_STR-$kdev1-$kdev2"
		mdadm --create /dev/md/$MDNAME $dev1 $dev2 \
		      --level=${RAID_LEVEL} --raid-devices=${RAID_DEVCNT} \
		      --chunk=${RAID_CHUNK} ${QUIET}
	done
}


test_mdraid(){
	TGT=$( ls /dev/md/MD* | head -1 )
	JOBS=1
	echo "Testing $TGT"
	for PAT in 'write' 'read' 'randrw' 'randread' 'randwrite'; do
		for BLK in 4k 8k 16k 32k 512k 1M 2M; do
			echo "Testing $PAT with $BLK fio against $TGT"
			fio --filename=${TGT} \
			    --direct=1 \
			    --rw=${PAT} \
			    --ioengine=libaio \
			    --iodepth=32 \
			    --numjobs=${JOBS} \
			    --runtime=360 \
			    --name="direct-${PAT}-${BLK}" \
			    --group_reporting  \
			    --bs=${BLK} \
			    --output-format='json+' | tee  "${PAT}-${BLK}.mdraid.fio.direct.json"
		done
	done
}
rm_mdraid
mk_mdraid
test_mdraid
