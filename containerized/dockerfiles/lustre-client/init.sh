#!/bin/bash
/install-lustre.sh
touch /etc/sysconfig/network
systemctl restart network
systemctl status network
source /lustre-client-wrapper.sh