#/bin/sh
set -e

get_header() {
	echo "ObjSize,Workers,Op-Type,Op-Count,Byte-Count" \
		",Avg-ResTime,Avg-ProcTime,60%-ResTime" \
		",80%-ResTime,90%-ResTime,95%-ResTime,99%-ResTime" \
		",100%-ResTime,Throughput,Bandwidth,Succ-Ratio"
}
get_data() {
for ARCHIVE in $(find $PWD -maxdepth 1 -type d -iname "archive*" | sort)
do
	echo $ARCHIVE
	OUTFILE="${ARCHIVE}.csv"
	get_header | tee ${OUTFILE}
	for OP in test_write test_read
	do
		for FILE in $(find "${ARCHIVE}"/ -name "w*-HARRIER_W???_OBJ*K.csv" )
		do
			BFILE=$(basename "${FILE}")
			WORKERS=$(echo "${BFILE}" \
				| awk -F '_' '{print $2}' \
				| sed 's/W//g')
			BS=$(echo ${BFILE}  \
				| awk -F '_' '{print $3}' \
				| sed 's/[OBJ|.csv]//g' \
				| sed -e :a -e 's/^.\{1,4\}$/0&/;ta')
			echo -n "$BS,$WORKERS," | tee -a "${OUTFILE}"
			cat ${FILE} | grep "${OP}" \
				| cut -d "," -f "3,4,5,6,7,8,9,10,11,12,13,14,15,16" \
				| tee -a "${OUTFILE}"
		done
	done
done
}

get_data
