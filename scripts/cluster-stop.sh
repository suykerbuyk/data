#!/bin/sh

cd /root/cos/ && ./stop-controller.sh
rm -rf /root/cos/log
# rm -rf /root/cos/archive

ssh root@lr02u31 'cd /root/cos/ && ./stop-driver.sh' &
ssh root@lr02u32 'cd /root/cos/ && ./stop-driver.sh' &
ssh root@lr02u33 'cd /root/cos/ && ./stop-driver.sh' &
wait

ssh root@lr02u31 'rm -rf /root/cos/log' &
ssh root@lr02u32 'rm -rf /root/cos/log' &
ssh root@lr02u33 'rm -rf /root/cos/log' &
wait
