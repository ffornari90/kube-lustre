FROM centos:7
RUN yum install -y perl epel-release
RUN rpm -ivh http://os-server.cr.cnaf.infn.it/distro/snapshots/20190806/CentOS7_x86_64_updates/kernel-headers-3.10.0-957.1.3.el7.x86_64.rpm && \
    rpm -ivh http://os-server.cr.cnaf.infn.it/distro/snapshots/20190806/CentOS7_x86_64_updates/kernel-devel-3.10.0-957.1.3.el7.x86_64.rpm
RUN yum install -y dkms http://os-server.cr.cnaf.infn.it/distro/snapshots/20190806/CentOS7_x86_64_updates/kernel-3.10.0-957.1.3.el7.x86_64.rpm
ADD install-lustre.sh /
ADD lustre-client-wrapper.sh /
CMD /install-lustre.sh && /lustre-client-wrapper.sh
