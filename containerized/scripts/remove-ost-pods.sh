#!/bin/bash
pods=(`kubectl get pods -n lustre | grep lustrefs | grep ost | awk '{print $1}'`)
kubectl delete pods -n lustre "${pods[@]}"
