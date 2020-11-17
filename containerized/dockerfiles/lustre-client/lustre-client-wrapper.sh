#!/bin/sh
[ "$DEBUG" == "1" ] && set -x
set -e

for i in FSNAME MGSNODE MOUNTPOINT; do
    if [ -z "$(eval "echo \"\$$i"\")" ]; then
        >&2 echo "Error: variable $i is not specified"
        exit 1
    fi
done

if [ "${#FSNAME}" -gt "8" ]; then
    >&2 echo "Error: variable FSNAME cannot be greater than 8 symbols, example:"
    >&2 echo "       FSNAME=lustre1"
    exit 1
fi

if [ ! -z "$CHROOT" ]; then
    MODPROBE="chroot $CHROOT modprobe"
else
    MODPROBE="modprobe"
fi

# Check for module
$MODPROBE lustre

cleanup() {
    set +e

    # kill tail process if exist
    kill $TAILF_PID 2>/dev/null
    # kill mount process if exist
    kill -SIGINT $MOUNT_PID 2>/dev/null && wait $MOUNT_PID

    # umount lustre target if mounted
    umount -v "$MOUNTPOINT"

    # export zpool if imported
    if $ZPOOL list "$POOL" &>/dev/null; then
        $ZPOOL export -f "$POOL"
    fi

    # mark secondary if drbd backend
    [ "$HA_BACKEND" == "drbd" ] && $DRBDADM secondary "$RESOURCE_NAME"

    rmdir "$MOUNT_TARGET" 2>/dev/null

    exit 0
}

# Set exit trap
trap cleanup SIGINT SIGHUP SIGTERM EXIT

# Start daemon
/usr/sbin/init
