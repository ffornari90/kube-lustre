#!/bin/bash
for pod in $(kubectl get pods -n lustre | grep drbd | grep -v configurator | awk '{print $1}'); do kubectl -n lustre exec -ti $pod -- bash -c "drbdsetup down \$RESOURCE_NAME"; done
