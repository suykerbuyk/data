#!/bin/sh


DIRS=" mach.2/deadline_scheduler_4k_read_ahead/8kChunk \
       mach.2/deadline_scheduler_4k_read_ahead/128kChunk\
       evans/deadline_scheduler_4k_read_ahead"

for DIR in $DIRS
do
	TEST_NAME="$(echo $DIR | sed 's/\//-/g')"
	CSV_FILE="${TEST_NAME}.csv"
	echo "Creating: ${CSV_FILE}"
	HEADER="config,timestamp,fio_pattern,ioengine,direct,iodepth,job_name"
	HEADER="${HEADER},blocksize,numjobs,runtime_secs,read_io_bytes"
	HEADER="${HEADER},read_bw_bytes,read_bw_mean,read_iops_mean,write_io_bytes"
	HEADER="${HEADER},write_bw_bytes,write_bw_mean,write_iops_mean"
	echo "${HEADER}">"${CSV_FILE}"
	for SRC_FILE in $(ls ${DIR}/*.json)
	do
        	echo -n "${TEST_NAME}," >>"${CSV_FILE}"
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
exit 1


FNAME_PREFIX="mdraid4k mdraid8k mdraid16k mdraid32k mdraid64k mdraid128k"

parse_for_zfs_config() {
  for TEST in ${FNAME_PREFIX}; do
     CSV_FILE="${TEST}.csv"
     echo "Creating: ${CSV_FILE}"
     HEADER="config,timestamp,fio_pattern,ioengine,direct,iodepth,job_name"
     HEADER="${HEADER},blocksize,numjobs,runtime_secs,read_io_bytes"
     HEADER="${HEADER},read_bw_bytes,read_bw_mean,read_iops_mean,write_io_bytes"
     HEADER="${HEADER},write_bw_bytes,write_bw_mean,write_iops_mean"
     echo "${HEADER}">"${CSV_FILE}"
     for SRC_FILE in $(ls ${TEST}*.json)
     do
        echo -n "${TEST}," >>"${CSV_FILE}"
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
parse_for_zfs_config
for F in $(ls *.csv); do cat $F | sed 's/,4k,/,0004k,/g'>${F}.new; mv -f ${F}.new ${F};done
for F in $(ls *.csv); do cat $F | sed 's/,8k,/,0008k,/g'>${F}.new; mv -f ${F}.new ${F};done
for F in $(ls *.csv); do cat $F | sed 's/,16k,/,0016k,/g'>${F}.new; mv -f ${F}.new ${F};done
for F in $(ls *.csv); do cat $F | sed 's/,32k,/,0032k,/g'>${F}.new; mv -f ${F}.new ${F};done
for F in $(ls *.csv); do cat $F | sed 's/,64k,/,0064k,/g'>${F}.new; mv -f ${F}.new ${F};done
for F in $(ls *.csv); do cat $F | sed 's/,128k,/,0128k,/g'>${F}.new; mv -f ${F}.new ${F};done
for F in $(ls *.csv); do cat $F | sed 's/,256k,/,0256k,/g'>${F}.new; mv -f ${F}.new ${F};done
for F in $(ls *.csv); do cat $F | sed 's/,512k,/,0512k,/g'>${F}.new; mv -f ${F}.new ${F};done
for F in $(ls *.csv); do cat $F | sed 's/,1M,/,1024k,/g'>${F}.new; mv -f ${F}.new ${F};done
for F in $(ls *.csv); do cat $F | sed 's/,2M,/,2048k,/g'>${F}.new; mv -f ${F}.new ${F};done
