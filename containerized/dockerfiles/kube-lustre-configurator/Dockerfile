FROM centos:7
RUN yum install -y epel-release && yum install -y jq \
 && curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
 && chmod +x /usr/local/bin/kubectl
ADD kube-lustre-configurator.sh lustre-client.yaml lustre-ost-server.yaml lustre-mdt-mgs-server.yaml /
CMD ["/kube-lustre-configurator.sh"]
