#!/bin/bash
/install-drbd.sh
touch /etc/sysconfig/network
systemctl restart network
systemctl status network
source /drbd-wrapper.sh
/install-lustre.sh
source /lustre-wrapper.sh

