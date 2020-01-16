#/bin/sh
BASE_DIR="$PWD/archive.harrier.03"
echo "ObjSize,Workers,Op-Type,Op-Count,Byte-Count,Avg-ResTime,Avg-ProcTime,60%-ResTime,80%-ResTime,90%-ResTime,95%-ResTime,99%-ResTime,100%-ResTime,Throughput,Bandwidth,Succ-Ratio"
for f in $(find $BASE_DIR/ -name "w*-HARRIER_W???_OBJ*K.csv" )
do
	bf=$(basename $f)
	workers=$(echo $bf | awk -F '_' '{print $2}' | sed 's/W//g')
	bs=$(echo $bf | awk -F '_' '{print $3}' | sed 's/[OBJ|.csv]//g')
	echo -n "$bs,$workers,"
	cat $f | grep "test_write" | cut -d "," -f "3,4,5,6,7,8,9,10,11,12,13,14,15,16" 
done
echo "ObjSize,Workers,Op-Type,Op-Count,Byte-Count,Avg-ResTime,Avg-ProcTime,60%-ResTime,80%-ResTime,90%-ResTime,95%-ResTime,99%-ResTime,100%-ResTime,Throughput,Bandwidth,Succ-Ratio"
for f in $(find $BASE_DIR/ -name "w*-HARRIER_W???_OBJ*K.csv" )
do
	bf=$(basename $f)
	workers=$(echo $bf | awk -F '_' '{print $2}' | sed 's/W//g')
	bs=$(echo $bf | awk -F '_' '{print $3}' | sed 's/[OBJ|.csv]//g')
	echo -n "$bs,$workers,"
	cat $f | grep "test_read" | cut -d "," -f "3,4,5,6,7,8,9,10,11,12,13,14,15,16" 
done
