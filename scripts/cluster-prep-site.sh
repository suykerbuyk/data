#!/bin/sh
set -e

for d in 26 27 28; do ssh lr02u$d yum install -y docker; done
for d in 26 27 28; do scp /etc/containers/registries.conf lr02u$d:/etc/containers/ ; done
for d in 26 27 28; do scp /etc/sysconfig/docker lr02u$d:/etc/sysconfig/ ; done
for d in 26 27 28; do ssh lr02u$d systemctl enable docker --now; done
ansible mons -m shell -a "docker pull cadmin:5000/rhceph/rhceph-3-rhel7"
for d in 26 27 28; do rsync -avr /etc/ceph/ lr02u$d:/etc/ceph/ ; done
cd /usr/share/ceph-ansible/

