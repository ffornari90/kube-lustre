FROM centos/systemd
ADD install-drbd.sh add-RHEL74-compat-hack.patch /
ADD drbd-wrapper.sh template.res /
ADD install-lustre.sh /
ADD lustre-wrapper.sh /
ADD start.sh /
ADD init.sh /
ADD fix-rpmdb.sh /
ADD ksocklnd.conf /
ADD ptlrpc.conf /
ADD zfs.conf /
RUN yum install -y patch perl epel-release nc net-tools
RUN rpm -ivh http://os-server.cr.cnaf.infn.it/distro/snapshots/20200113/CentOS7_x86_64_updates/kernel-headers-3.10.0-1062.9.1.el7.x86_64.rpm && \
    rpm -ivh http://os-server.cr.cnaf.infn.it/distro/snapshots/20200113/CentOS7_x86_64_updates/kernel-devel-3.10.0-1062.9.1.el7.x86_64.rpm
RUN yum install -y dkms http://os-server.cr.cnaf.infn.it/distro/snapshots/20200113/CentOS7_x86_64_updates/kernel-3.10.0-1062.9.1.el7.x86_64.rpm
RUN curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
 && chmod +x /usr/local/bin/kubectl
CMD ["/start.sh"]
