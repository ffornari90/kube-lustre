#!/bin/sh
[ "$DEBUG" == "1" ] && set -x
set -e


# default parameters
[ -z "$KERNEL_VERSION" ] && KERNEL_VERSION="$(uname -r)"
VERSION="8.4.11-1"
UTILS_VERSION="9.12.2-1"


install_drbd_dkms() {

    if ! $YUM -y install "kernel-devel-uname-r == $KERNEL_VERSION"; then
        >&2 echo "Error: Can not found kernel-headers for current kernel"
        >&2 echo "       try to ugrade kernel package then reboot your system"
        >&2 echo "       or install kernel-headers package manually"
        exit 1
    fi

    # install dkms
    $RPM -q dkms || $YUM -y install dkms

    # install drbd-dkms module
    if ! $DKMS status -m drbd -v "$VERSION" | grep -q "."; then

        rm -rf "$CHROOT/usr/src/drbd-$VERSION"
        $CURL "https://www.linbit.com/downloads/drbd/8.4/drbd-$VERSION.tar.gz" | tar -xzf - -C "$CHROOT/usr/src"

        #PATCH_PATH="$PWD/add-RHEL74-compat-hack.patch"
        #cd "$CHROOT/usr/src/drbd-$VERSION"
        #patch -p1 < "$PATCH_PATH"
        #cd -

        cat > "$CHROOT/usr/src/drbd-$VERSION/dkms.conf" << EOF
PACKAGE_NAME="drbd"
PACKAGE_VERSION="$VERSION"
MAKE[0]="make KVER=\${kernelver} KDIR=\${kernel_source_dir} -C drbd"
BUILT_MODULE_NAME[0]=drbd
DEST_MODULE_LOCATION[0]=/kernel/drivers/block
BUILT_MODULE_LOCATION[0]=drbd
CLEAN="make -C drbd clean"
AUTOINSTALL=yes
EOF

        $DKMS add "drbd/$VERSION"
    fi

    $DKMS install "drbd/$VERSION" -k "$KERNEL_VERSION"
}

install_drbd_utils() {
    $YUM -y install "http://elrepo.org/linux/elrepo/el7/x86_64/RPMS/drbd84-utils-$UTILS_VERSION.el7.elrepo.x86_64.rpm"
}

# if chroot is set, use yum and rpm from chroot
if [ ! -z "$CHROOT" ]; then
    RPM="chroot $CHROOT rpm"
    YUM="chroot $CHROOT yum"
    DKMS="chroot $CHROOT dkms"
    CURL="chroot $CHROOT curl"
else
    RPM="rpm"
    YUM="yum"
    DKMS="dkms"
    CURL="curl"
fi

# check for distro
if [ "$(sed 's/.*release\ //' "$CHROOT/etc/redhat-release" | cut -d. -f1)" != "7" ]; then
    >&2 echo "Error: Host system not supported"
    exit 1
fi

# check for module
if ! (find "$CHROOT/lib/modules/$KERNEL_VERSION" -name drbd.ko.xz | grep -q "."); then
    install_drbd_dkms
fi

# check for drbd-utils
if ! chroot "${CHROOT:-/}" command -v drbdadm; then
    install_drbd_utils
fi

# final check for module
if ! (find "$CHROOT/lib/modules/$KERNEL_VERSION" -name drbd.ko.xz | grep -q "."); then
     >&2 echo "Error: Can not found installed drbd module for current kernel"
     exit 1
fi

echo "Success!"
