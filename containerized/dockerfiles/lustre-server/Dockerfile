FROM centos:7
RUN yum install -y patch perl epel-release nc
RUN rpm -ivh http://os-server.cr.cnaf.infn.it/distro/snapshots/20190806/CentOS7_x86_64_updates/kernel-headers-3.10.0-957.1.3.el7.x86_64.rpm && \
    rpm -ivh http://os-server.cr.cnaf.infn.it/distro/snapshots/20190806/CentOS7_x86_64_updates/kernel-devel-3.10.0-957.1.3.el7.x86_64.rpm
RUN yum install -y dkms http://os-server.cr.cnaf.infn.it/distro/snapshots/20190806/CentOS7_x86_64_updates/kernel-3.10.0-957.1.3.el7.x86_64.rpm
ADD install-drbd.sh add-RHEL74-compat-hack.patch /
ADD install-lustre.sh /
ADD drbd-wrapper.sh template.res /
ADD lustre-wrapper.sh /
RUN curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
 && chmod +x /usr/local/bin/kubectl
CMD /install-drbd.sh && /install-lustre.sh && /drbd-wrapper.sh && /lustre-wrapper.sh
