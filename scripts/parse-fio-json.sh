#!/bin/sh


# DIRS="mach2/wce_disabled/noop_4096 \
#       mach2/wce_disabled/noop_131072 \
#       mach2/wce_disabled/deadline_65536 \
#       mach2/wce_disabled/deadline_4096 \
#       mach2/wce_disabled/noop_32768 \
#       mach2/wce_disabled/noop_8192 \
#       evans_paired/wce_enabled/deadline_4096 \
#       evans/wce_enabled/deadline_4096"

DIRS=""
for DATA in $(find . | grep test.log)
do
	DIR=$(dirname $DATA)
	DIR=$(echo $DIR | cut --complement -c 1-2)
	DIRS="$DIRS $DIR"
done
process_json_data() {
	echo "Processing JSON Data files"
	for DIR in $DIRS
	do
		DRV_PLATFORM="$(echo $DIR | awk -F '/' '{print $1}' | sed 's/ //g')"
		DRV_WCE="$(echo $DIR | awk -F '/' '{print $2}' | sed 's/ //g')"
		DRV_SCHEDULER="$(echo $DIR | awk -F '/' '{print $3}' | sed 's/ //g')"
		#TEST_NAME="$(echo $DIR | sed 's/\//-/g')"
		TEST_NAME="${DRV_PLATFORM}.${DRV_WCE}.${DRV_SCHEDULER}"
		CSV_FILE="${TEST_NAME}.csv"
		echo "Creating: ${CSV_FILE}"
		HEADER="config,srcfile,raid0blksize,timestamp,fio_pattern,ioengine,direct,iodepth,job_name"
		HEADER="${HEADER},blocksize,numjobs,runtime_secs,read_io_bytes"
		HEADER="${HEADER},read_bw_bytes,read_bw_mean,read_iops_mean,write_io_bytes"
		HEADER="${HEADER},write_bw_bytes,write_bw_mean,write_iops_mean"
		echo "${HEADER}">"${CSV_FILE}"
		for SRC_FILE in $(ls ${DIR}/*.json)
		do
			echo -n "${TEST_NAME}," >>"${CSV_FILE}"
			SRC="$(basename ${SRC_FILE})"
			echo -n "${SRC}," >>"${CSV_FILE}"
			RAID0_BLK_SIZE="$(echo ${SRC} | egrep -o 'data_.*_[0-9]*k-' | sed 's/-//g' | sed 's/_/ /g' | awk '{print $NF}')"
			FIO_BLK_SIZE="$(echo ${SRC}  | egrep -o '*-[0-9]*k-' | sed 's/-//g' | sed 's/_/ /g' | awk '{print $NF}')"
			if [[ "X${RAID0_BLK_SIZE}" == "X" ]] ; then
				RAID0_BLK_SIZE="N/A"
			fi
			echo -n "${RAID0_BLK_SIZE}," >>"${CSV_FILE}"
			cat "${SRC_FILE}" | \
			jq -r '. | [
			.timestamp_ms, 
			."global options".rw,
			."global options".ioengine,
			."global options".direct,
			."global options".iodepth,
			.jobs[]."job options".name,
			.jobs[]."job options".bs,
			."global options".numjobs,
			."global options".runtime,
			.jobs[].read.io_bytes,
			.jobs[].read.bw_bytes,
			.jobs[].read.bw_mean,
			.jobs[].read.iops_mean,
			.jobs[].write.io_bytes,
			.jobs[].write.bw_bytes,
			.jobs[].write.bw_mean,
			.jobs[].write.iops_mean
			] | @csv' | sed 's/"//g' >>"${CSV_FILE}"
		done
	done
}

process_csv_data() {
	echo "Cleaning up CSV files"
	for F in $(ls *.csv); do cat $F | \
		sed -i 's/,4k,/,0004k,/g;   s/,8k,/,0008k,/g;   s/,16k,/,0016k,/g; s/,32k,/,0032k,/g; s/,64k,/,0064k,/g; s/,128k,/,0128k,/g' ${F}
		sed -i 's/,256k,/,0256k,/g; s/,512k,/,0512k,/g; s/,1M,/,1024k,/g;  s/,2M,/,2048k,/g;  s/,4M,/,4096k,/g;  s/,8M,/,8192k,/g' ${F}
	done
	echo "Building composite CSV file"
	cat $(ls *.csv | head -1) | head -1 >all_sorted.tmp
	for F in $(ls *.csv); do cat $F | grep -v "config" | sort  -t ',' -k 1 -k 3 -k 4 -k 10 -n -k 8 >>all_sorted.tmp ; done
	mv all_sorted.tmp all_sorted.csv
}
process_csv_data

