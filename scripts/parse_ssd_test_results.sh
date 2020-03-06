#!/bin/sh
set -e


HEADER="ObjSize, Workers, WriteBytes, DriverWriteBW, WriteBW, DriverWriteIOPs, WriteIOPs,   ReadBytes, DriverReadBW, ReadBW,DriverReadIOPs, ReadIOPs, WriteRespTime, ReadRespTime, WriteProcTime, ReadProcTime "

DriverNodeCount=3
DriverProcessCount=8
DriverWorkerCount=$((DriverNodeCount * DriverProcessCount))
OsdCount=36

FILE_PAT="MACH2_128K_STRIPE_SSD_512K_RA_SCH_NOOP"
get_avg() {
	source_file="$1"
	search_trigger="$2"
	search_field="$3"
	field_count=$(cat $source_file | grep "$search_trigger" | wc -l)
	avg=$(cat $source_file | grep "$search_trigger" | awk -F ',' '{print $'${search_field}'}' | awk '{sum += $1} END {avg=sum/24;printf "%d\n",avg}' )
	echo $avg
	
}
parse_csv_file() {
	DELIM_CNT=$(echo "${FILE_PAT}" | awk -F '_' '{print NF-1}')
	find $BASE_DIR/ -name "w*-${FILE_PAT}_W*_OBJ*K.csv" | \
	while read FILE
	do
		BF=$(basename $FILE)
		echo $BF >>file.list

		# Constnat data field offsets.
		FIELD_OP_TYPE=3
		FIELD_OP_COUNT=4
		FIELD_BYTE_COUNT=5
		FIELD_AVG_RES_TIME=6
		FIELD_AVG_PROC_TIME=7
		FIELD_THROUGHPUT=14
		FIELD_BANDWIDTH=15
		

		write_bandwidth=$(get_avg $FILE "test_write,write,write" $FIELD_BANDWIDTH)
		write_bandwidth=$(echo "     ${write_bandwidth}" | grep -o '........$')
		read_bandwidth=$(get_avg $FILE "test_read,read,read" $FIELD_BANDWIDTH)
		read_bandwidth=$(echo "     ${read_bandwidth}" | grep -o '........$')
		write_bytes=$(get_avg $FILE "test_write,write,write" $FIELD_BYTE_COUNT)
		write_bytes=$(echo "        ${write_bytes}" | grep -o '............$')
		read_bytes=$(get_avg $FILE "test_read,read,read" $FIELD_BYTE_COUNT)
		read_bytes=$(echo "        ${read_bytes}" | grep -o '............$')
		write_iops=$(get_avg $FILE "test_write,write,write" $FIELD_THROUGHPUT)
		write_iops=$(echo "        ${write_iops}" | grep -o '........$')
		read_iops=$(get_avg $FILE "test_read,read,read" $FIELD_THROUGHPUT)
		read_iops=$(echo "        ${read_iops}" | grep -o '........$')
		write_resp_time=$(get_avg $FILE "test_write,write,write" $FIELD_AVG_RES_TIME)
		write_resp_time=$(echo "        ${write_resp_time}" | grep -o '........$')
		read_resp_time=$(get_avg $FILE "test_read,read,read" $FIELD_AVG_RES_TIME)
		read_resp_time=$(echo "        ${read_resp_time}" | grep -o '........$')
		write_proc_time=$(get_avg $FILE "test_write,write,write" $FIELD_AVG_PROC_TIME)
		write_proc_time=$(echo "        ${write_proc_time}" | grep -o '........$')
		read_proc_time=$(get_avg $FILE "test_read,read,read" $FIELD_AVG_PROC_TIME)
		read_proc_time=$(echo "        ${read_proc_time}" | grep -o '........$')
		obj_size=$(echo "$BF" | sed 's/_/ /g' | sed 's/.csv//g' | sed 's/OBJ//g' | sed 's/ W/ /g' | cut -d ' ' -f $(($DELIM_CNT +3)))
		worker_cnt=$(echo "$BF" | sed 's/_/ /g' | sed 's/.csv//g' | sed 's/OBJ//g' | sed 's/ W/ /g' | cut -d ' ' -f $(($DELIM_CNT +2)))
		obj_size=$(echo "0000${obj_size}"| grep -o '.....$')
		worker_cnt=$(echo "0000${worker_cnt}" | grep -o '....$')
		# test_write_bw=$((write_bandwidth * DriverWorkerCount))
		# test_write_bw=$(echo "     ${test_write_bw}" | grep -o '........$')
		# test_write_iops=$((write_iops * DriverWorkerCount))
		# test_write_iops=$(echo "     ${test_write_iops}" | grep -o '........$')
		# test_read_bw=$((read_bandwidth * DriverWorkerCount))
		# test_read_bw=$(echo "     ${test_read_bw}" | grep -o '........$')
		# test_read_iops=$((read_iops * DriverWorkerCount))
		# test_read_iops=$(echo "     ${test_read_iops}" | grep -o '........$')
		# echo "$obj_size, $worker_cnt, $write_bytes, $write_bandwidth, $test_write_bw,  $write_iops, $test_write_iops, $read_bytes, $read_bandwidth, $test_read_bw,  $read_iops, $test_read_iops, $write_resp_time, $read_resp_time, $write_proc_time, $read_proc_time"
		echo "$obj_size, $worker_cnt, $write_bytes, $write_bandwidth, $write_bw,  $write_iops, $write_iops, $read_bytes, $read_bandwidth, $read_bw,  $read_iops, $read_iops, $write_resp_time, $read_resp_time, $write_proc_time, $read_proc_time"
	done 
}
BASE_DIR="$PWD/archive"
echo "DriverCount, $DriverWorkerCount"
echo "OSD_Count, $OsdCount"
echo
echo $HEADER
parse_csv_file | sort
