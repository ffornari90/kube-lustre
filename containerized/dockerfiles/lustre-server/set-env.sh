#!/bin/bash
export NODE1_NAME=k8s-lustre-1.novalocal
export NODE1_IP=10.0.1.8
export NODE2_NAME=k8s-lustre-2.novalocal
export NODE2_IP=10.0.1.5
export MGSNODE="10.0.1.8@eth0:10.0.1.5@eth0"
export SERVICENODE="10.0.1.8@eth0:10.0.1.5@eth0"
ip=$(ifconfig eth0 | grep inet | awk '$1=="inet" {print $2}')
netmask=$(ifconfig eth0 | grep inet | awk '$1=="inet" {print $4}')
broadcast=$(ifconfig eth0 | grep inet | awk '$1=="inet" {print $6}')
printf 'DEVICE=eth0
IPADDR=%s
NETMASK=%s
NETWORK=10.244.0.0
BROADCAST=%s
ONBOOT=yes
NAME=ether\n' \
"${ip}" "${netmask}" "${broadcast}" | tee /etc/sysconfig/network-scripts/ifcfg-eth0
touch /etc/sysconfig/network
modprobe -v lnet
lnetctl lnet configure
systemctl restart network
