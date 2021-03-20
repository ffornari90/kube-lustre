#!/bin/bash
pods=(`kubectl get pods -n lustre | grep lustrefs | grep mdt | awk '{print $1}'`)
kubectl delete pods -n lustre "${pods[@]}"
