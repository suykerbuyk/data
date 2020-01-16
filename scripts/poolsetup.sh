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
ceph osd erasure-code-profile set rgw k=4 m=2 stripe_unit=1048576 crush-failure-domain=osd
ceph osd pool create default.rgw.buckets.data 1024 1024 erasure rgw
#ceph osd erasure-code-profile set rgw k=4 m=2 stripe_unit=1048576 crush-failure-domain=host
#
# Delete the existing pools
#
echo "Deleting existing pools"
ceph osd pool delete rbd rbd --yes-i-really-really-mean-it
ceph osd pool delete default.rgw.meta default.rgw.meta --yes-i-really-really-mean-it
ceph osd pool delete default.rgw.buckets.data default.rgw.buckets.data --yes-i-really-really-mean-it
ceph osd pool delete default.rgw.buckets.index default.rgw.buckets.index --yes-i-really-really-mean-it
#
# Recreate the pools
#
echo "Creating new pools"
ceph osd pool create default.rgw.buckets.data 1024 1024 erasure rgw default.rgw.buckets.data 1000000000
ceph osd pool create default.rgw.buckets.index 128 128 
ceph osd pool create default.rgw.meta 64 64 
ceph osd pool application enable default.rgw.buckets.data rgw
ceph osd pool application enable default.rgw.buckets.index rgw
ceph osd pool application enable default.rgw.meta rgw
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
