#!/bin/bash
for pod in $(kubectl get pods -n lustre | grep lustrefs | grep drbd | awk '{print $1}'); do kubectl -n lustre exec $pod -- bash -c "yum -y install zfs zfs-dkms &"; done
