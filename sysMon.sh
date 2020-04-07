#!/bin/sh

printf  "freeMem    user   nice system iowait  steal   idle\n"
while [ 1 ]
do
	FREE=$(free | grep Mem | awk -F ' ' '{print $3}'| tr -d [:space:])
	CPU=$(iostat -c   | grep '       ' | sed 's/       //g')
	printf "$FREE $CPU\n"
	sleep 5
done
