#!/bin/sh

FNAME_PREFIX="mdraid4k mdraid8k mdraid16k"

parse_for_zfs_config() {
  for TEST in ${FNAME_PREFIX}; do
     CSV_FILE="${TEST}.csv"
     echo "Creating: ${CSV_FILE}"
     HEADER="config,timestamp,fio_pattern,ioengine,direct,iodepth,job_name"
     HEADER="${HEADER},blocksize,filesize,numjobs,runtime_secs,read_io_bytes"
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
            .jobs[]."job options".size,
            .jobs[]."job options".numjobs,
            .jobs[]."job options".runtime,
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
