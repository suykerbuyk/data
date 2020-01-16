#!/bin/sh

TPLFILE="$PWD/test.xml"
LOAD_WORKERS=48
PREP_WORKERS=48
TEST_NAME="TEST_IT"
TEST_DESCRIPTION="Description of test"
OBJ_SIZE=4
CONTAINER_MIN=1
CONTAINER_MAX=192
OBJ_CNT_MIN=1
OBJ_CNT_MAX=1000
CPREFIX=s3harrier
ACCESS_KEY=12345
SECRET_KEY=67890
RUNTIME=120
ENDPOINT="http://object.lyve.colo.seagate.com"


Create_RW_TemplateFile() {
cat <<END_OF_TEMPLATE >$TPLFILE
<?xml version="1.0" encoding="UTF-8" ?>
<workload name="__TEST_NAME__" description="__TEST_DESCRIPTION__">
  <storage type="s3" config="accesskey=__ACCESS_KEY__;secretkey=__SECRET_KEY__;endpoint=__ENDPOINT__" />
  <workflow>
    <workstage name="init">
      <work type="init" workers="__PREP_WORKERS__" config="cprefix=__CPREFIX__;containers=r(__CONTAINER_MIN__,__CONTAINER_MAX__)" />
    </workstage>
    <workstage name="prepare">
      <work type="prepare" division="object" workers="__PREP_WORKERS__" config="cprefix=__CPREFIX__;containers=r(__CONTAINER_MIN__,__CONTAINER_MAX__);objects=r(__OBJ_CNT_MIN__,__OBJ_CNT_MAX__);sizes=c(__OBJ_SIZE__)KB" />
    </workstage>
    <workstage name="test_write">
      <work name="main" division="object" workers="__LOAD_WORKERS__" runtime="__RUNTIME__">
        <operation type="write" ratio="100" config="cprefix=__CPREFIX__;containers=u(1__CONTAINER_MIN__,1__CONTAINER_MAX__);objects=u(__OBJ_CNT_MIN__,__OBJ_CNT_MAX__);sizes=c(__OBJ_SIZE__)KB" />
      </work>
    </workstage>
    <workstage name="test_read">
      <work name="main" workers="__LOAD_WORKERS__" runtime="__RUNTIME__">
        <operation type="read" division="object" ratio="100" config="cprefix=__CPREFIX__;containers=u(__CONTAINER_MIN__,__CONTAINER_MAX__);objects=u(__OBJ_CNT_MIN__,__OBJ_CNT_MAX__)" />
      </work>
    </workstage>
    <workstage name="cleanup">
      <work type="cleanup" workers="__PREP_WORKERS__" config="cprefix=__CPREFIX__;containers=r(__CONTAINER_MIN__,__CONTAINER_MAX__);objects=r(__OBJ_CNT_MIN__,__OBJ_CNT_MAX__)" />
      <work type="cleanup" workers="__PREP_WORKERS__" config="cprefix=__CPREFIX__;containers=r(1__CONTAINER_MIN__,1__CONTAINER_MAX__);objects=r(__OBJ_CNT_MIN__,__OBJ_CNT_MAX__)" />
    </workstage>
    <workstage name="dispose">
      <work type="dispose" workers="__PREP_WORKERS__" config="cprefix=__CPREFIX__;containers=r(__CONTAINER_MIN__,__CONTAINER_MAX__)" />
    </workstage>
  </workflow>
</workload>
END_OF_TEMPLATE
}
SetTemplateParameters(){
ex $TPLFILE<<-END_OF_EDIT
	:%s#__LOAD_WORKERS__#$LOAD_WORKERS#g
	:%s#__PREP_WORKERS__#$PREP_WORKERS#g
	:%s#__TEST_NAME__#$TEST_NAME#g
	:%s#__TEST_DESCRIPTION__#$TEST_DESCRIPTION#g
	:%s#__OBJ_SIZE__#$OBJ_SIZE#g
	:%s#__CONTAINER_MIN__#$CONTAINER_MIN#g
	:%s#__CONTAINER_MAX__#$CONTAINER_MAX#g
	:%s#__OBJ_CNT_MIN__#$OBJ_CNT_MIN#g
	:%s#__OBJ_CNT_MAX__#$OBJ_CNT_MAX#g
	:%s#__CPREFIX__#$CPREFIX#g
	:%s#__ACCESS_KEY__#$ACCESS_KEY#g
	:%s#__SECRET_KEY__#$SECRET_KEY#g
	:%s#__ENDPOINT__#$ENDPOINT#g
	:%s#__RUNTIME__#$RUNTIME#g
	:w
	:q	
	END_OF_EDIT
}

for OBJ_SIZE in 4 16 64 256 1024 4096 8192
#for OBJ_SIZE in 4096
do
    for LOAD_WORKERS in 24 48 96 144 192 240 256 288 312 336 360 384 408
    # for LOAD_WORKERS in 192
    do
	TEST_NAME=$(printf 'HARRIER_W%03d_OBJ%03dK' $LOAD_WORKERS $OBJ_SIZE)
	TEST_DESCRIPTION=$(printf 'HARRIER_TEST_Workers=%03d_OBJ_SIZE=%03dK' $LOAD_WORKERS $OBJ_SIZE)
	Create_RW_TemplateFile
	SetTemplateParameters
	sh ./cli.sh submit $TPLFILE
	#cat $TPLFILE
	# read a
    done
done
