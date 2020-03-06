#!/bin/bash
#
# Stop the RGWs
#
echo "Stopping RGWs on all nodes"
ssh lr02u26 systemctl stop ceph-radosgw@rgw.lr02u26
ssh lr02u27 systemctl stop ceph-radosgw@rgw.lr02u27
ssh lr02u28 systemctl stop ceph-radosgw@rgw.lr02u28
#
# Make sure the EC Profile is up to date
#
# ceph osd erasure-code-profile rm rgw --yes-i-really-really-mean-it
# ceph osd erasure-code-profile set rgw k=4 m=2 stripe_unit=131072 crush-failure-domain=osd
#ceph osd erasure-code-profile set rgw k=4 m=2 stripe_unit=1048576 crush-failure-domain=osd
# ceph osd pool create default.rgw.buckets.data 1024 1024 erasure rgw
# ceph osd crush rule create-replicated replicated-ssd default host ssd
#
# Delete the existing pools
#
echo "Deleting existing pools"
ceph osd pool delete rbd rbd --yes-i-really-really-mean-it
ceph osd pool delete default.rgw.meta default.rgw.meta --yes-i-really-really-mean-it
ceph osd pool delete default.rgw.buckets.data default.rgw.buckets.data --yes-i-really-really-mean-it
ceph osd pool delete default.rgw.buckets.index default.rgw.buckets.index --yes-i-really-really-mean-it
ceph osd pool delete default.rgw.buckets.data default.rgw.buckets.data --yes-i-really-really-mean-it
ceph osd erasure-code-profile rm rgw
#
# Recreate the pools for RADOS Gateway
#
echo "Creating new pools"
ceph osd crush rule create-replicated replicated-ssd default host ssd
ceph osd erasure-code-profile set rgw k=4 m=2 stripe_unit=131072 crush-failure-domain=osd
ceph osd pool create default.rgw.buckets.data 1024 1024 erasure rgw
ceph osd pool create default.rgw.buckets.data 1024 1024 erasure rgw
ceph osd pool create default.rgw.buckets.data 1024 1024 erasure rgw default.rgw.buckets.data 1000000000
ceph osd pool create default.rgw.buckets.index 128 128 replicated replicated-ssd
ceph osd pool create default.rgw.meta 64 64 
ceph osd pool application enable default.rgw.buckets.data rgw
ceph osd pool application enable default.rgw.buckets.index rgw
ceph osd pool application enable default.rgw.meta rgw
#
# Recreate the pool for RBD
#
#ceph osd pool create rbd 2048 2048 replicated # Create RBD pool on HDDs
#ceph osd pool create rbd 512 512 replicated replicated-ssd # Create RBD pool on SSDs
#ceph osd pool application enable rbd rbd
#
# Start the RGWs
#
echo "Starting RGWs on all nodes"
ssh lr02u26 systemctl start ceph-radosgw@rgw.lr02u26
ssh lr02u27 systemctl start ceph-radosgw@rgw.lr02u27
ssh lr02u28 systemctl start ceph-radosgw@rgw.lr02u28
#
# Create test user
#
echo "Creating a dedicated user for the test 12345/67890"
radosgw-admin user create --uid=lyve --display-name="Seagate Mach 2 Testing" --access-key=12345 --secret=67890 --max-buckets=0 --system
#
# Set CRUSH rule so that all backing meta pool for RGW are located on SSD
#
for p in $(ceph osd pool ls | grep -v data | grep -v rbd)
do
	ceph osd pool set $p crush_rule replicated-ssd
done
