#!/bin/sh
[ "$DEBUG" == "1" ] && set -x
set -e

for i in FSNAME DEVICE; do
    if [ -z "$(eval "echo \"\$$i"\")" ]; then
        >&2 echo "Error: variable $i is not specified"
        exit 1
    fi
done

NODE1_METADISK=${NODE1_METADISK:-internal}
NODE2_METADISK=${NODE1_METADISK:-internal}
MOUNT_DIR=${MOUNT_DIR:-/var/lib/lustre}
[ "$FORCE_CREATE" == "1" ] && FORCE_CREATE_CMD="--force"

case "$TYPE" in
    ost )
        TYPE_CMD="--ost"
        POOL="${POOL:-$FSNAME-ost${INDEX}}"
        NAME="${NAME:-ost${INDEX}}"
    ;;
    mdt )
        TYPE_CMD="--mdt"
        POOL="${POOL:-$FSNAME-mdt${INDEX}}"
        NAME="${NAME:-mdt${INDEX}}"
    ;;
    mgs )
        TYPE_CMD="--mgs"
        POOL="${POOL:-$FSNAME-mds}"
        NAME="${NAME:-mgs}"
    ;;
    mdt-mgs )
        TYPE_CMD="--mdt --mgs"
        POOL="${POOL:-$FSNAME-mdt${INDEX}-mgs}"
        NAME="${NAME:-mdt${INDEX}-mgs}"
    ;;
    * )
        >&2 echo "Error: variable TYPE is unspecified, or specified wrong"
        >&2 echo "       TYPE=<mgs|mdt|ost|mdt-mgs>"
        exit 1
    ;;
esac

if [ "${#FSNAME}" -gt "8" ]; then
    >&2 echo "Error: variable FSNAME cannot be greater than 8 symbols, example:"
    >&2 echo "       FSNAME=lustre1"
    exit 1
else
    FSNAME_CMD="--fsname=$FSNAME"
fi

if [ "$TYPE" != "mgs" ]; then
    if [ -z "$INDEX" ]; then
        >&2 echo "Error: variable INDEX is not specified, example:"
        >&2 echo "       INDEX=1"
        exit 1
    else
        INDEX_CMD="--index=$INDEX"
    fi
fi

if ( [ "$TYPE" == "ost" ] || [ "$TYPE" == "mdt" ] ); then
    if [ -z "$MGSNODE" ]; then
        >&2 echo "Error: variable MGSNODE is not specified, example:"
        >&2 echo "       MGSNODE=\"10.28.38.11@tcp,10.28.38.12@tcp\""
        exit 1
    else
        MGSNODE_CMD="--mgsnode=$MGSNODE"
    fi
fi

if [ "$HA_BACKEND" == "drbd" ]; then
    case "" in
        "$RESOURCE_NAME" )
            >&2 echo "Error: variable RESOURCE_NAME is not specified for HA_BACKEND=drbd"
            exit 1
        ;;
        "$SERVICENODE" )
            >&2 echo "Error: variable SERVICENODE is not specified for HA_BACKEND=drbd, example:"
            >&2 echo "       SERVICENODE=\"10.28.38.13@tcp,10.28.38.14@tcp\""
            exit 1
        ;;
    esac
    SERVICENODE_CMD="--servicenode=$SERVICENODE"
fi

if [ ! -z "$CHROOT" ]; then
    DRBDADM="chroot $CHROOT drbdadm"
    WIPEFS="chroot $CHROOT wipefs"
    MODPROBE="chroot $CHROOT modprobe"
    ZPOOL="chroot $CHROOT zpool"
    SYSTEMCTL="chroot $CHROOT systemctl"
    MKFS_LUSTRE="chroot $CHROOT mkfs.lustre"
else
    DRBDADM="drbdadm"
    WIPEFS="wipefs"
    MODPROBE="modprobe"
    ZPOOL="zpool"
    SYSTEMCTL="systemctl"
    MKFS_LUSTRE="mkfs.lustre"
fi

# Write config
rm -f "$CHROOT/etc/drbd.d/$RESOURCE_NAME.res"
eval "echo \"$(cat template.res | sed 's/"/\\"/g')\"" > "$CHROOT/tmp/$RESOURCE_NAME.res"
$DRBDADM sh-nop -t "/tmp/$RESOURCE_NAME.res"
mv "$CHROOT/tmp/$RESOURCE_NAME.res" "$CHROOT/etc/drbd.d/$RESOURCE_NAME.res"

# Check for module
echo 'alias bond0 bonding
options bond0 mode=2 miimon=100 xmit_hash_policy=layer3+4
options bonding max_bonds=1' | tee /etc/modprobe.d/bond.conf
$MODPROBE -v bonding
$MODPROBE -v ksocklnd
$MODPROBE -v lnet
lnetctl lnet configure
if lnetctl net show | grep -q 'tcp'; then
  lnetctl net show
else
  lnetctl net add --net tcp --if bond0
  lnetctl net show
fi
$MODPROBE -v osd_zfs

if [ "$TYPE" == "ost" ]; then
    $MODPROBE -v ofd
    $MODPROBE -v mgc
    $MODPROBE -v ost
fi

if [ "$TYPE" == "mdt-mgs" ]; then
    $MODPROBE -v mgs
    $MODPROBE -v mdt
fi

if [ "$TYPE" == "mdt" ]; then
    $MODPROBE -v mgc
    $MODPROBE -v mdt
fi

if [ "$TYPE" == "mgs" ]; then
    $MODPROBE -v mgs
fi

$MODPROBE -v lod
$MODPROBE -v mdd
$MODPROBE -v osp
$MODPROBE -v zfs
$MODPROBE -v lustre

# Check for drbd resource
if [ "$HA_BACKEND" == "drbd" ]; then
    $DRBDADM status "$RESOURCE_NAME" 1>/dev/null
    $DRBDADM -- --overwrite-data-of-peer primary "$RESOURCE_NAME"
fi

# Create mount target
#MOUNT_TARGET="$MOUNT_DIR/$POOL/$NAME"
MOUNT_TARGET="$MOUNT_DIR"
SYSTEMD_UNIT="$(echo $MOUNT_TARGET | sed -e 's/-/\\x2d/g' -e 's/\//-/g' -e 's/^-//').mount"
SYSTEMD_UNIT_FILE="$CHROOT/run/systemd/system/$SYSTEMD_UNIT"

cleanup() {
    [ "$?" != "0" ] && KUBE_NOTIFY=0
    set +e

    # kill tail process if exist
    kill $TAILF_PID 2>/dev/null
    # kill mount process if exist
    kill -SIGINT $MOUNT_PID 2>/dev/null && wait $MOUNT_PID
    # kill zpool process if exist
    kill -SIGINT $ZPOOL_PID 2>/dev/null && wait $ZPOOL_PID

    # umount lustre target if mounted
    if $SYSTEMCTL is-active "$SYSTEMD_UNIT"; then
        $SYSTEMCTL stop "$SYSTEMD_UNIT"
    fi

    rm -f "$SYSTEMD_UNIT_FILE"

    # export zpool if imported
    if $ZPOOL list "$POOL" &>/dev/null; then
        $ZPOOL export -f "$POOL"
    fi

    # mark secondary if drbd backend
    [ "$HA_BACKEND" == "drbd" ] && $DRBDADM secondary "$RESOURCE_NAME"

    rmdir "$MOUNT_TARGET" 2>/dev/null

    # kill the pod for not wait when Terminating are finished
    [ "$KUBE_NOTIFY" == "1" ] && kubectl delete pod "$RESOURCE_NAME-0" --force --grace-period=0

    exit 0
}

# Set exit trap
trap cleanup SIGINT SIGHUP SIGTERM EXIT

if $WIPEFS "$DEVICE" | grep -q "."; then
    # Prepare drive
    $MKFS_LUSTRE $FSNAME_CMD $FORCE_CREATE_CMD $MGSNODE_CMD $SERVICENODE_CMD $INDEX_CMD $TYPE_CMD --backfstype=zfs --force-nohostid "$POOL/$NAME" "$DEVICE"
else
    # Import zfs-pool
    if ! $ZPOOL list | grep -q "^$POOL "; then
        $ZPOOL import -o cachefile=none "$POOL" &
        ZPOOL_PID=$!
        wait $ZPOOL_PID
    fi
fi

# Write unit
cat > "$SYSTEMD_UNIT_FILE" <<EOT
[Mount]
What=$POOL/$NAME
Where=$MOUNT_TARGET
Type=lustre
EOT

# Start daemon
$SYSTEMCTL daemon-reload
if ! $SYSTEMCTL start "$SYSTEMD_UNIT"; then
    # print error
    $SYSTEMCTL status "$SYSTEMD_UNIT" | grep 'mount\[' | sed 's/^.*\]: //g' >&2
    exit 1
fi &

MOUNT_PID=$!
wait $MOUNT_PID

mv /ksocklnd.conf /etc/modprobe.d/
mv /ptlrpc.conf /etc/modprobe.d/
mv /zfs.conf /etc/modprobe.d/

$MODPROBE -v ksocklnd
$MODPROBE -v ptlrpc
$MODPROBE -v zfs

if [[ "$TYPE" == "mdt-mgs" || "$TYPE" == "mgs" ]]; then
    lctl set_param -P osc.*.checksums=0
    lctl set_param -P timeout=600
    lctl set_param -P at_min=250
    lctl set_param -P at_max=600
    lctl set_param -P ldlm.namespaces.*.lru_size=2000
    lctl set_param -P osc.*.max_rpcs_in_flight=64
    lctl set_param -P osc.*.max_dirty_mb=1024
    lctl set_param -P llite.*.max_read_ahead_mb=1024
    lctl set_param -P llite.*.max_cached_mb=81920
    lctl set_param -P llite.*.max_read_ahead_per_file_mb=1024
    lctl set_param -P subsystem_debug=0
fi

fsname="${POOL}/${NAME}"
zfs set mountpoint=none ${fsname}
zfs set sync=disabled ${fsname}
zfs set atime=off ${fsname}
zfs set redundant_metadata=most ${fsname}
zfs set xattr=sa ${fsname}
zfs set recordsize=1M ${fsname}

# Sleep calm
tail -f /dev/null &
TAILF_PID=$!
wait $TAILF_PID
