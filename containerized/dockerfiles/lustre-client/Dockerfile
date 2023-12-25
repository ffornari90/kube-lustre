FROM centos/systemd
ADD install-lustre.sh /
ADD lustre-client-wrapper.sh /
ADD init.sh /
ADD start.sh /
ADD fix-rpmdb.sh /
RUN yum install -y perl epel-release
RUN rpm -ivh http://os-server.cr.cnaf.infn.it/distro/snapshots/20200113/CentOS7_x86_64_updates/kernel-headers-3.10.0-1062.9.1.el7.x86_64.rpm && \
    rpm -ivh http://os-server.cr.cnaf.infn.it/distro/snapshots/20200113/CentOS7_x86_64_updates/kernel-devel-3.10.0-1062.9.1.el7.x86_64.rpm
RUN yum install -y dkms http://os-server.cr.cnaf.infn.it/distro/snapshots/20200113/CentOS7_x86_64_updates/kernel-3.10.0-1062.9.1.el7.x86_64.rpm
CMD ["/start.sh"]
