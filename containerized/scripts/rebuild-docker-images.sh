#!/bin/bash
export TOPDIR="${PWD}/.."
docker login
cd ${TOPDIR}/dockerfiles/lustre-client
docker build --tag ffornari/kube-lustre:lustre-client-containerized .
docker push ffornari/kube-lustre:lustre-client-containerized
cd ${TOPDIR}/dockerfiles/lustre-server
docker build --tag ffornari/kube-lustre:lustre-server-containerized .
docker push ffornari/kube-lustre:lustre-server-containerized
cd ${TOPDIR}/dockerfiles/kube-lustre-configurator
docker build --tag ffornari/kube-lustre:kube-lustre-configurator-containerized .
docker push ffornari/kube-lustre:kube-lustre-configurator-containerized
