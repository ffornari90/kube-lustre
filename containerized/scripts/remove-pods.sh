#!/bin/bash
kubectl delete daemonset -n lustre --all && kubectl delete sts -n lustre --all && kubectl delete -f ../yaml/kube-lustre-configurator.yaml
