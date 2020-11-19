#!/bin/bash
touch /etc/sysconfig/network
systemctl restart network
/install-lustre.sh
#source /lustre-client-wrapper.sh
