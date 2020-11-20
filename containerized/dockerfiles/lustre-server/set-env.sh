#!/bin/bash
kubectl get pod -o=custom-columns=IP:.status.podIP,NAME:.metadata.name -n lustre | grep "${FSNAME}" | tee /etc/hosts
nodes=(`kubectl get pod -o=custom-columns=NAME:.metadata.name,IP:.status.podIP -n lustre | grep "${TYPE%-*}" | awk '{print $1}'`)
ips=(`kubectl get pod -o=custom-columns=NAME:.metadata.name,IP:.status.podIP -n lustre | grep "${TYPE%-*}" | awk '{print $2}'`)
export NODE1_NAME="${nodes[0]}"
export NODE1_IP="${ips[0]}"
export NODE2_NAME="${nodes[1]}"
export NODE2_IP="${ips[1]}"
export MGSNODE="${ips[0]}@eth0:${ips[1]}@eth0"
export SERVICENODE="${ips[0]}@eth0:${ips[1]}@eth0"
ip=$(ifconfig eth0 | grep inet | awk '$1=="inet" {print $2}')
netmask=$(ifconfig eth0 | grep inet | awk '$1=="inet" {print $4}')
broadcast=$(ifconfig eth0 | grep inet | awk '$1=="inet" {print $6}')
network=$(ip route show | grep "${ip}" | awk '{print $1}')
network="${network%/*}"
printf 'DEVICE=eth0
IPADDR=%s
NETMASK=%s
NETWORK=%s
BROADCAST=%s
ONBOOT=yes
NAME=ether\n' \
"${ip}" "${netmask}" "${network}" "${broadcast}" | tee /etc/sysconfig/network-scripts/ifcfg-eth0
touch /etc/sysconfig/network
systemctl restart network
systemctl status network
modprobe -v lnet
lnetctl lnet configure
lnetctl net show
