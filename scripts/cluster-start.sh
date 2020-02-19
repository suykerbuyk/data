#!/bin/sh
/usr/share/ceph-ansible/poolsetup.sh
ssh root@lr02u31 'cd /root/cos/ && ./start-driver.sh 8 172.16.18.22' &
ssh root@lr02u32 'cd /root/cos/ && ./start-driver.sh 8 172.16.18.25' &
ssh root@lr02u33 'cd /root/cos/ && ./start-driver.sh 8 172.16.18.31' &
wait
cd /root/cos/ && ./start-controller.sh
