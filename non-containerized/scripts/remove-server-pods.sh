#!/bin/bash
pods=(`kubectl get pods -n lustre | grep lustrefs | grep -v -E 'client|drbd' | awk '{print $1}'`)
kubectl delete pods -n lustre "${pods[@]}"
