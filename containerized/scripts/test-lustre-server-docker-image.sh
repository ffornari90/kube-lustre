#!/bin/bash
docker run -v /stor/lustrefs:/stor/lustrefs \
    -v /dev:/dev \
    --net=host --privileged \
    -e DEBUG=1 \
    -e RESOURCE_NAME=lustrefs-mdt0-mgs \
    -e DEVICE=/dev/drbd0 \
    -e NODE1_NAME=k8s-lustre-1.novalocal \
    -e NODE1_DISK=/dev/vdb \
    -e NODE1_IP=10.0.1.8 \
    -e NODE1_PORT=7788 \
    -e NODE2_NAME=k8s-lustre-2.novalocal \
    -e NODE2_DISK=/dev/vdb \
    -e NODE2_IP=10.0.1.5 \
    -e NODE2_PORT=7788 \
    -e HA_BACKEND=drbd \
    -e MOUNT_DIR=/stor/lustrefs \
    -e FSNAME=lustrefs \
    -e TYPE=mdt-mgs \
    -e INDEX=0 \
    -e MGSNODE="10.0.1.8@tcp:10.0.1.5@tcp" \
    -e SERVICENODE="10.0.1.8@tcp:10.0.1.5@tcp" \
    ffornari/kube-lustre:lustre-server-containerized
