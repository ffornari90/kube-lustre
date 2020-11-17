#!/bin/bash
[ "$DEBUG" == "1" ] && set -x
set -e

if [ ! -z "$CHROOT" ]; then
    SYSTEMCTL="chroot $CHROOT systemctl"
else
    SYSTEMCTL="systemctl"
fi

MOUNT_DIR=${MOUNT_DIR:-/var/lib/lustre}

POOL="${POOL:-$FSNAME-ost${INDEX}}"
NAME="${NAME:-ost${INDEX}}"

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

$SYSTEMCTL enable "$SYSTEMD_UNIT"
