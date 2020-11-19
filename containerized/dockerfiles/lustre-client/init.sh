#!/bin/bash
touch /etc/sysconfig/network
systemctl restart network
/install-lustre.sh
modprobe lnet
lnetctl lnet configure
#source /lustre-client-wrapper.sh
