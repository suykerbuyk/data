#!/bin/sh

set -e

CHUNK=4
LEVEL=0
DEVCNT=2

IDX=0
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
        echo "mdadm --create /dev/md/$MDNAME $dev1 $dev2 --level=$LEVEL --raid-devices=$DEVCNT --chunk=$CHUNK"
        mdadm --create /dev/md/$MDNAME $dev1 $dev2 --level=$LEVEL --raid-devices=$DEVCNT --chunk=$CHUNK
done

