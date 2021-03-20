#!/bin/bash
pods=(`kubectl get pods -n lustre | grep lustrefs | grep drbd | awk '{print $1}'`)
kubectl delete pods -n lustre "${pods[@]}"
