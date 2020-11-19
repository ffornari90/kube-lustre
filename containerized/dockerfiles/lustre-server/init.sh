#!/bin/bash
touch /etc/sysconfig/network
systemctl restart network
/install-drbd.sh
/install-lustre.sh
modprobe osd_zfs
modprobe mgs 
modprobe mdt
modprobe lnet
lnetctl lnet configure
#source /drbd-wrapper.sh
#source /lustre-wrapper.sh
