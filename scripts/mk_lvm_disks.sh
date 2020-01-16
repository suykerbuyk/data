#!/bin/sh

set -e

DSK_PREFIX='wwn-0x5000c500a'
DSK_PATH='/dev/disk/by-id'

DRV_COUNT=$(ls $DSK_PATH/$DSK_PREFIX* | cut -c 1-38 | sort -u| wc -l)
LUN_COUNT=$(ls $DSK_PATH/$DSK_PREFIX* | cut -c 1-38 --complement | sort -u | wc -l )

# Simple sanity check on device parsing
if [ $LUN_COUNT != 1 ]; then
	echo "ERROR: Detected LUN count should 1, not $LUN_COUNT"
	exit 1
fi

# Device index
IDX=0
for DEV in $( ls $DSK_PATH/$DSK_PREFIX* | cut -c 1-38 | sort -u ); do
	# echo "LUN0=$LUN_0  LUN1=$LUN_1"
        KDEV="/dev/$(ls -lah $DEV | awk -F '/' '{print $7}')"
	echo "KDEV=$KDEV"
	

        echo "pvcreate $KDEV"
        pvcreate $KDEV

        IDX_STR=$(printf '%03d' $IDX)
	VG_NAME="vg_$IDX_STR"
        echo " vgcreate $VG_NAME $KDEV"
        vgcreate $VG_NAME $KDEV
	
	LV_NAME="lv_$IDX_STR"
	echo "  lvcreate -n $LV_NAME -l 100%FREE $VG_NAME"
	lvcreate -n $LV_NAME -l 100%FREE $VG_NAME
        IDX=$( expr $IDX + 1 )
done

