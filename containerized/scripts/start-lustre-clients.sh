#!/bin/bash
for pod in $(kubectl get pods -n lustre | grep lustrefs | grep client | awk '{print $1}'); do kubectl -n lustre exec $pod -- bash -c "/lustre-client-wrapper.sh > /lustre-client-wrapper.log 2>&1 &"; done
