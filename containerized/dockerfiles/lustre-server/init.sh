#!/bin/bash
touch /etc/sysconfig/network
systemctl restart network
/install-drbd.sh
/install-lustre.sh
#source /drbd-wrapper.sh
#source /lustre-wrapper.sh
