#!/bin/bash
export TOPDIR="${PWD}/.."
docker login
cd ${TOPDIR}/dockerfiles/lustre-client
docker build --build-arg MOUNTPOINT=/stor/lustrefs --build-arg FSNAME=lustrefs --build-arg MGSNODE=k8s-lustre-1.novalocal:k8s-lustre-2.novalocal --tag ffornari/kube-lustre:lustre-client-containerized .
docker push ffornari/kube-lustre:lustre-client-containerized
cd ${TOPDIR}/dockerfiles/lustre-mdt-mgs-server
docker build --build-arg MOUNT_DIR=/stor/lustrefs --build-arg FSNAME=lustrefs --build-arg INDEX=0 --tag ffornari/kube-lustre:lustre-mdt-mgs-server-containerized .
docker push ffornari/kube-lustre:lustre-mdt-mgs-server-containerized
cd ${TOPDIR}/dockerfiles/lustre-ost-server
docker build --build-arg MOUNT_DIR=/stor/lustrefs --build-arg FSNAME=lustrefs --build-arg INDEX=0 --tag ffornari/kube-lustre:lustre-ost-server-containerized .
docker push ffornari/kube-lustre:lustre-ost-server-containerized
cd ${TOPDIR}/dockerfiles/kube-lustre-configurator
docker build --tag ffornari/kube-lustre:kube-lustre-configurator-containerized .
docker push ffornari/kube-lustre:kube-lustre-configurator-containerized
