#!/bin/bash
/install-drbd.sh
/install-lustre.sh
modprobe -v osd_zfs
#modprobe -v mgs 
#modprobe -v mdt
#source /drbd-wrapper.sh
#source /lustre-wrapper.sh
