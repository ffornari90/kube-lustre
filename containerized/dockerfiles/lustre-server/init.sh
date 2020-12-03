#!/bin/bash
/install-drbd.sh
/install-lustre.sh
touch /etc/sysconfig/network
systemctl restart network
systemctl status network
source /drbd-wrapper.sh
source /lustre-wrapper.sh
