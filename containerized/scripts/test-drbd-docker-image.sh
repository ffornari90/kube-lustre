#!/bin/bash
docker run --net=host --privileged \
    -e DEBUG=1 \
    -e RESOURCE_NAME=lustrefs-ost2 \
    -e DEVICE=/dev/drbd0 \
    -e NODE1_NAME=cs-007.cr.cnaf.infn.it \
    -e NODE1_DISK=/dev/sdz \
    -e NODE1_IP=131.154.128.199 \
    -e NODE1_PORT=7788 \
    -e NODE2_NAME=cs-008.cr.cnaf.infn.it \
    -e NODE2_DISK=/dev/sdz \
    -e NODE2_IP=131.154.128.202 \
    -e NODE2_PORT=7788 \
    ffornari/kube-lustre:drbd-containerized
