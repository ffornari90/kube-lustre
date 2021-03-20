#!/bin/bash
/fix-rpmdb.sh
/install-drbd.sh
touch /etc/sysconfig/network
systemctl restart network
systemctl status network
/install-lustre.sh
#source /lustre-wrapper.sh

