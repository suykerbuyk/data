#!/bin/sh

FNAME_PREFIX="mach2_zfs"

parse_for_zfs_config() {
  for TEST in ${FNAME_PREFIX}; do
    CSV_FILE="${TEST}.csv"
    echo "Creating: ${CSV_FILE}"
    echo "zfs_config,timestamp,pattern,config,blocksize,filesize,numjobs,runtime_secs,read_io_bytes,read_bw_bytes,read_bw_mean,read_iops_mean,write_io_bytes,write_bw_bytes,write_bw_mean,write_iops_mean" >"${CSV_FILE}"
    for SRC_FILE in $(ls ${TEST}*.json); do
    ZFS_CONFIG=$(echo ${SRC_FILE} \
      | sed -e 's/[_|.]/ /g' \
      | sed -e 's/-/ /g' \
      | awk '{print $3}')
    echo -n "${ZFS_CONFIG}," >>"${CSV_FILE}"
    cat "${SRC_FILE}" | \
      jq -r '. | [
        .timestamp_ms,
        .jobs[]."job options".rw,
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
