#!/bin/bash
/install-drbd.sh
source /drbd-wrapper.sh
touch /etc/sysconfig/network
systemctl restart network
systemctl status network
/install-lustre.sh
source /lustre-wrapper.sh
