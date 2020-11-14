#!/bin/bash
export TOPDIR="${PWD}/.."
docker login
cd ${TOPDIR}/dockerfiles/drbd
docker build --tag ffornari/kube-lustre:drbd-containerized .
docker push ffornari/kube-lustre:drbd-containerized
cd ${TOPDIR}/dockerfiles/drbd-install
docker build --tag ffornari/kube-lustre:drbd-install-containerized .
docker push ffornari/kube-lustre:drbd-install-containerized
cd ${TOPDIR}/dockerfiles/lustre
docker build --tag ffornari/kube-lustre:lustre-containerized .
docker push ffornari/kube-lustre:lustre-containerized
cd ${TOPDIR}/dockerfiles/lustre-client
docker build --tag ffornari/kube-lustre:lustre-client-containerized .
docker push ffornari/kube-lustre:lustre-client-containerized
cd ${TOPDIR}/dockerfiles/lustre-install
docker build --tag ffornari/kube-lustre:lustre-2.10.8-install-containerized .
docker push ffornari/kube-lustre:lustre-2.10.8-install-containerized
cd ${TOPDIR}/dockerfiles/kube-lustre-configurator
docker build --tag ffornari/kube-lustre:kube-lustre-configurator-containerized .
docker push ffornari/kube-lustre:kube-lustre-configurator-containerized
