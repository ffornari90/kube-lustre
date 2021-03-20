#!/bin/bash
for pod in $(kubectl get pods -n lustre | grep lustrefs | grep -v -E 'client|configurator|drbd' | awk '{print $1}'); do kubectl -n lustre exec -ti $pod -- bash -c "for p in \$(zpool list -H -o name); do zpool export \$p; done"; done
for pod in $(kubectl get pods -n lustre | grep lustrefs | grep -v -E 'client|configurator' | awk '{print $1}'); do kubectl -n lustre exec -ti $pod -- bash -c "drbdsetup down \$RESOURCE_NAME"; done
