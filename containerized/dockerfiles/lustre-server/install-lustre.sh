#!/bin/sh
[ "$DEBUG" == "1" ] && set -x
set -e

# default parameters
[ -z "$KERNEL_VERSION" ] && KERNEL_VERSION="$(uname -r)"

install_lustre_repo() {
    RELEASE="lustre-2.12.4"

    cat > "$CHROOT/etc/yum.repos.d/lustre.repo" <<EOF
[lustre-server]
name=lustre-server
baseurl=https://downloads.whamcloud.com/public/lustre/$RELEASE/el7/server
# exclude=*debuginfo*
gpgcheck=0

[lustre-client]
name=lustre-client
baseurl=https://downloads.whamcloud.com/public/lustre/$RELEASE/el7/client
# exclude=*debuginfo*
gpgcheck=0

[e2fsprogs-wc]
name=e2fsprogs-wc
baseurl=https://downloads.whamcloud.com/public/e2fsprogs/1.45.2.wc1/el7
# exclude=*debuginfo*
gpgcheck=0
EOF

}

install_dkms_module() {
    local MODULE="$1"
    if [ "$MODULE" == "lustre" ]; then
        local VERSION="$($RPM -q "$1-zfs-dkms" | sed "s/^$1-zfs-dkms-\([^-]\+\).*/\1/")"
        $DKMS install "$MODULE-zfs/$VERSION" -k "$KERNEL_VERSION"
    else
        local VERSION="$($RPM -q "$1-dkms" | sed "s/^$1-dkms-\([^-]\+\).*/\1/")"
        $DKMS install "$MODULE/$VERSION" -k "$KERNEL_VERSION"
    fi
}

# if chroot is set, use yum and rpm from chroot
if [ ! -z "$CHROOT" ]; then
    RPM="chroot $CHROOT rpm"
    YUM="chroot $CHROOT yum"
    DKMS="chroot $CHROOT dkms"
else
    RPM="rpm"
    YUM="yum"
    DKMS="dkms"
fi

# check for distro
if [ "$(sed 's/.*release\ //' "$CHROOT/etc/redhat-release" | cut -d. -f1)" != "7" ]; then
    >&2 echo "Error: Host system not supported"
    exit 1
fi


# check for module
if ! (find "$CHROOT/lib/modules/$KERNEL_VERSION" -name zfs.ko.xz | grep -q "."); then
    INSTALL_ZFS=1
fi

if ! (find "$CHROOT/lib/modules/$KERNEL_VERSION" -name lustre.ko.xz | grep -q "."); then
    INSTALL_LUSTRE=1
fi

if [ "$INSTALL_ZFS" == 1 ] || [ "$INSTALL_LUSTRE" == 1 ]; then

    if ! $YUM -y install "kernel-devel-uname-r == $KERNEL_VERSION"; then
        >&2 echo "Error: Can not found kernel-headers for current kernel"
        >&2 echo "       try to ugrade kernel package then reboot your system"
        >&2 echo "       or install kernel-headers package manually"
        exit 1
    fi

    $RPM -q --quiet epel-release || $YUM -y install epel-release
    install_lustre_repo "$VERSION"
fi

if [ "$INSTALL_ZFS" == 1 ]; then
    $YUM -y install zfs zfs-dkms
    install_dkms_module spl
    install_dkms_module zfs
fi

if [ "$INSTALL_LUSTRE" == 1 ]; then
    $YUM -y install lustre lustre-dkms
    install_dkms_module lustre
fi

# final check for module
if ! (find "$CHROOT/lib/modules/$KERNEL_VERSION" -name zfs.ko.xz | grep -q "."); then
     >&2 echo "Error: Can not found installed zfs module for current kernel"
     exit 1
fi

echo "Success!"
