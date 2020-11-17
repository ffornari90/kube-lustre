#!/bin/bash
[ "$DEBUG" == "1" ] && set -x
set -e

if [ ! -z "$CHROOT" ]; then
    SYSTEMCTL="chroot $CHROOT systemctl"
else
    SYSTEMCTL="systemctl"
fi

MOUNT_DIR=${MOUNT_DIR:-/var/lib/lustre}

case "$TYPE" in
    ost )
        POOL="${POOL:-$FSNAME-ost${INDEX}}"
        NAME="${NAME:-ost${INDEX}}"
    ;;
    mdt )
        POOL="${POOL:-$FSNAME-mdt${INDEX}}"
        NAME="${NAME:-mdt${INDEX}}"
    ;;
    mgs )
        POOL="${POOL:-$FSNAME-mds}"
        NAME="${NAME:-mgs}"
    ;;
    mdt-mgs )
        POOL="${POOL:-$FSNAME-mdt${INDEX}-mgs}"
        NAME="${NAME:-mdt${INDEX}-mgs}"
    ;;
    * )
        >&2 echo "Error: variable TYPE is unspecified, or specified wrong"
        >&2 echo "       TYPE=<mgs|mdt|ost|mdt-mgs>"
        exit 1
    ;;
esac

# Create mount target
mkdir -p "$CHROOT/run/systemd/system"
MOUNT_TARGET="$MOUNT_DIR"
SYSTEMD_UNIT="$(echo $MOUNT_TARGET | sed -e 's/-/\\x2d/g' -e 's/\//-/g' -e 's/^-//').mount"
SYSTEMD_UNIT_FILE="$CHROOT/run/systemd/system/$SYSTEMD_UNIT"

# Write unit
cat > "$SYSTEMD_UNIT_FILE" <<EOT
[Mount]
What=$POOL/$NAME
Where=$MOUNT_TARGET
Type=lustre
EOT

$SYSTEMCTL daemon-reload
$SYSTEMCTL enable "$SYSTEMD_UNIT"
