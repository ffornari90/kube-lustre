#!/bin/bash
for pod in $(kubectl get pods -n lustre | grep lustrefs | grep -v drbd | grep ost | awk '{print $1}'); do kubectl -n lustre exec $pod -- bash -c "/lustre-wrapper.sh > /lustre-wrapper.log 2>&1 &"; done
