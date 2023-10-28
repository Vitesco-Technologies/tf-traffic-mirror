#!/bin/bash
# Copyright 2023 Uli Heilmeier, Vitesco Technologies
#
# SPDX-License-Identifier: Apache-2.0

device_name="/dev/nvme1n1"
mount_point="/data"

#Updating repos und install additional tools
export DEBIAN_FRONTEND=noninteractive
apt update
apt upgrade -y
apt install -yq xfsprogs tshark termshark screen unzip

# Configure wireshark group (as dpkg-reconfigure would do it)
addgroup --quiet --system wireshark
chown root:wireshark /usr/bin/dumpcap
chmod u=rwx,g=rx,o=r /usr/bin/dumpcap
setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
usermod -a -G wireshark ubuntu
usermod -a -G wireshark ssm-user

# Mount Data volume
# Wait for ebs volume to be attached
while [ ! -e $(readlink -f $device_name) ]; do echo Waiting for EBS volume to attach; sleep 5; done

devpath=$(readlink -f $device_name)
mkdir $mount_point

mkfs -t xfs $devpath

devid=$(blkid $devpath -o value -s UUID)
devtype=$(blkid $devpath -o value -s TYPE)
echo "UUID=$devid $mount_point $devtype defaults,nofail  0  2" | sudo tee -a /etc/fstab > /dev/null
mount $devpath $mount_point

# Allow wireshark group to write to data mountpoint
chgrp wireshark $mount_point
chmod g+w $mount_point

# Adding some examples to bash history to make life easier
echo "tshark -i ens6 -n 'udp port 4789'" >> ~ubuntu/.bash_history
echo "tshark -i ens6 -n -Y 'ip.addr in {10.198.128.13 172.29.10.9 10.219.38.134} and dns.qry.name' -T fields -e dns.qry.name 'udp port 4789'" >> ~ubuntu/.bash_history
echo "tshark -i ens6 -n -Y 'tcp.port in {80 443}' -O http 'udp port 4789'" >> ~ubuntu/.bash_history

# Install AWS Cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws
