#!/bin/sh

DRIVER_NODES="lr02u31 lr02u32 lr02u33"
DRIVER_NODE_CNT=$(echo $DRIVER_NODES | wc -w)
TPLFILE="$PWD/newtest.xml"
BASE_TEST_NAME="MACH2_128K_STRIPE_SSD"
MAX_WORKER_PROCESSES=8
PREP_PROCESS_WORKERS=48
LOAD_PROCESS_THREADS=48
TEST_NAME="MACHII_128K_STRIP"
TEST_DESCRIPTION="Description of test"
OBJ_SIZE=4
CONTAINER_MIN_W=1
CONTAINER_MAX_W=1000
CONTAINER_MIN_R=1001
CONTAINER_MAX_R=2000
OBJ_CNT_MIN=1
OBJ_CNT_MAX=100
CPREFIX=s3harrier
ACCESS_KEY=12345
SECRET_KEY=67890
RUNTIME=180
TIMEOUT=60000
OBJS_PER_WORKER=40
MAX_OBJS_PER_RUN=480
ENDPOINT="http://object.lyve.colo.seagate.com"
DRIVER_NAME='driver'
WORKER_DIVISION='object'


Create_Prep_TestSection() {
	truncate -s 0 "${TPLFILE}"
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>">>"${TPLFILE}"
	echo "<workload name=\"$TEST_NAME\" description=\"$TEST_DESCRIPTION\">">>"${TPLFILE}"
	echo "  <storage type=\"s3\" timeout=\"$TIMEOUT\" config=\"accesskey=${ACCESS_KEY};secretkey=${SECRET_KEY};endpoint=${ENDPOINT}\" />">>"${TPLFILE}"
	echo "  <workflow>">>"${TPLFILE}"
	echo "    <workstage name=\"init\">">>"${TPLFILE}"
	echo "      <work type=\"init\" workers=\"${PREP_PROCESS_WORKERS}\" config=\"cprefix=${CPREFIX};containers=r(${CONTAINER_MIN_W},${CONTAINER_MAX_W})\" />">>"${TPLFILE}"
	echo "      <work type=\"init\" workers=\"${PREP_PROCESS_WORKERS}\" config=\"cprefix=${CPREFIX};containers=r(${CONTAINER_MIN_R},${CONTAINER_MAX_R})\" />">>"${TPLFILE}"
	echo "    </workstage>">>"${TPLFILE}"
	echo "    <workstage name=\"prepare\">">>"${TPLFILE}"
	echo "      <work type=\"prepare\" division=\"${WORKER_DIVISION}\" workers=\"${PREP_PROCESS_WORKERS}\" config=\"cprefix=${CPREFIX};containers=r(${CONTAINER_MIN_R},${CONTAINER_MAX_R});objects=r($OBJ_CNT_MIN,$OBJ_CNT_MAX);sizes=c(${OBJ_SIZE})KB\" />">>"${TPLFILE}"
	echo "    </workstage>">>"${TPLFILE}"
}

Create_Write_TestSection() {
	container_start=1
	echo "    <workstage name=\"test_write\">">>"${TPLFILE}"
	container_start=${CONTAINER_MIN_W}
	for driver in $DRIVER_NODES
	do
		for worker in $(seq 1 ${MAX_WORKER_PROCESSES})
		do
			driver_name="${driver}-${worker}"
			container_first=$container_start
			container_end=$((container_start + OBJS_PER_WORKER - 1 ))
			# echo "$driver_name : obj_first=$container_first obj_end=$container_end"
			echo "      <work name=\"write_${driver_name}\" driver=\"${driver_name}\" division=\"${WORKER_DIVISION}\" workers=\"${LOAD_PROCESS_THREADS}\" runtime=\"${RUNTIME}\">" >>"${TPLFILE}"
        		echo "        <operation type=\"write\" ratio=\"100\" config=\"cprefix=${CPREFIX};containers=r($container_start,$container_end);objects=u($OBJ_CNT_MIN,$OBJ_CNT_MAX);sizes=c($OBJ_SIZE)KB\" id=\"$driver_name\" />" >>"${TPLFILE}"
			echo "      </work>" >>"${TPLFILE}"
			container_start=$((container_start + OBJS_PER_WORKER))
		done
	done
	echo "    </workstage>">>"${TPLFILE}"
}
Create_Read_TestSection() {
	echo "    <workstage name=\"test_read\">">>"${TPLFILE}"
	container_start=${CONTAINER_MIN_R}
	for driver in $DRIVER_NODES
	do
		for worker in $(seq 1 ${MAX_WORKER_PROCESSES})
		do
			driver_name="${driver}-${worker}"
			container_first=$container_start
			container_end=$((container_start + OBJS_PER_WORKER - 1 ))
			# echo "$driver_name : obj_first=$container_first obj_end=$container_end"
			echo "      <work name=\"read_${driver_name}\" driver=\"${driver_name}\" division=\"${WORKER_DIVISION}\" workers=\"${LOAD_PROCESS_THREADS}\" runtime=\"${RUNTIME}\">" >>"${TPLFILE}"
        		echo "        <operation type=\"read\" ratio=\"100\" config=\"cprefix=${CPREFIX};containers=r($container_start,$container_end);objects=u($OBJ_CNT_MIN,$OBJ_CNT_MAX);sizes=c($OBJ_SIZE)KB\" id=\"$driver_name\" />" >>"${TPLFILE}"
			echo "      </work>" >>"${TPLFILE}"
			container_start=$((container_start + OBJS_PER_WORKER))
		done
	done
	echo "    </workstage>">>"${TPLFILE}"
}

Create_Clean_TestSection() {
	echo "    <workstage name=\"cleanup\">">>"${TPLFILE}"
	echo "      <work type=\"cleanup\" workers=\"${PREP_PROCESS_WORKERS}\" config=\"cprefix=${CPREFIX};containers=r(${CONTAINER_MIN_W},${CONTAINER_MAX_W});objects=r($OBJ_CNT_MIN,$OBJ_CNT_MAX)\" />">>"${TPLFILE}"
	echo "      <work type=\"cleanup\" workers=\"${PREP_PROCESS_WORKERS}\" config=\"cprefix=${CPREFIX};containers=r(${CONTAINER_MIN_R},${CONTAINER_MAX_R});objects=r($OBJ_CNT_MIN,$OBJ_CNT_MAX)\" />">>"${TPLFILE}"
	echo "    </workstage>">>"${TPLFILE}"
	echo "    <workstage name=\"dispose\">">>"${TPLFILE}"
	echo "      <work type=\"dispose\" workers=\"${PREP_PROCESS_WORKERS}\" config=\"cprefix=${CPREFIX};containers=r(${CONTAINER_MIN_W},${CONTAINER_MAX_W})\" />">>"${TPLFILE}"
	echo "      <work type=\"dispose\" workers=\"${PREP_PROCESS_WORKERS}\" config=\"cprefix=${CPREFIX};containers=r(${CONTAINER_MIN_R},${CONTAINER_MAX_R})\" />">>"${TPLFILE}"
	echo "    </workstage>">>"${TPLFILE}"
	echo "  </workflow>">>"${TPLFILE}"
	echo "</workload>">>"${TPLFILE}"
}

for OBJ_SIZE in 4 8 16 32 64 128 256 512 1024 2048 4096 8192 
do
	for LOAD_PROCESS_THREADS in 1 2 4 8 16 24 32 40 48 56 64 72
	do
		DRIVER_WORKERS=$(($MAX_WORKER_PROCESSES * $LOAD_PROCESS_THREADS))
		TEST_TOTAL_WORKERS=$(($DRIVER_WORKERS * $DRIVER_NODE_CNT))
		TEST_NAME=$(printf "${BASE_TEST_NAME}_W%03d_OBJ%03dK" $TEST_TOTAL_WORKERS $OBJ_SIZE)
		TEST_DESCRIPTION=$(printf '%s DriverNodeCount=%d DriverProcessCount=%d DriverProcessThreads=%d TotalWorkers=%04d OBJ_SIZE=%03dK' $BASE_TEST_NAME $DRIVER_NODE_CNT $MAX_WORKER_PROCESSES $LOAD_PROCESS_THREADS $TEST_TOTAL_WORKERS $OBJ_SIZE)
		Create_Prep_TestSection
		Create_Write_TestSection
		Create_Read_TestSection
		Create_Clean_TestSection
		sh ./cli.sh submit $TPLFILE
	done
done
