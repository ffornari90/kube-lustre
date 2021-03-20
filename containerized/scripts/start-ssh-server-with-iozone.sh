#!/bin/bash
yum install -y openssh-server openssh-clients perl perl-List-MoreUtils perl-Readonly
rpm -ivh https://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el7/en/x86_64/rpmforge/RPMS/iozone-3.424-1.el7.rf.x86_64.rpm
mkdir -p /var/run/sshd && mkdir -p /root/.ssh
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
touch /root/.ssh/authorized_keys
cat /etc/ssh/ssh_host_rsa_key.pub | cat >> /root/.ssh/authorized_keys
sed -ri 's/#   IdentityFile ~\/.ssh\/id_rsa/   IdentityFile ~\/.ssh\/id_rsa/' /etc/ssh/ssh_config
sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -ri 's/#Port 22/Port 22222/g' /etc/ssh/sshd_config
sed -ri 's/#   Port 22/   Port 22222/g' /etc/ssh/ssh_config
cp /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
cp /etc/ssh/ssh_host_rsa_key.pub /root/.ssh/id_rsa.pub
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
/usr/sbin/sshd -D
