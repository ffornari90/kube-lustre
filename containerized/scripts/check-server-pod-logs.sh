#!/bin/bash
for pod in $(kubectl get pods -n lustre | grep lustrefs | grep -v client | awk '{print $1}'); do kubectl logs -n lustre $pod | tail; done
