#!/bin/bash
for pod in $(kubectl get pods -n lustre | grep drbd | awk '{print $1}'); do kubectl logs -n lustre $pod | tail; printf '\n'; done
