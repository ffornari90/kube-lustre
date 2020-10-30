# kube-lustre

High-available Lustre filesystem concept with DRBD for Kubernetes.

## Concept

The project comprises a few simple docker-images with shell-scripts, and each one does its specific task.

Since lustre zfs and drbd work at the kernel level, which little bit does not fit into the docker's ideology, almost all actions are executed directly on the host machine.
Docker and Kubernetes are used here only as orchestration-system and ha-management framework.

What each image does?

| Image                         | Role                                                                                      |
|-------------------------------|-------------------------------------------------------------------------------------------|
| **kube-lustre-configurator**  | Reads [kube-lustre-config.yaml], then generates templates and assign resources to specific Kubernetes nodes |
| **lustre**                    | Makes lustre target, then imports zpool and mounts lustre target                          |
| **lustre-client**             | Mounts lustre filesystem                                                                  |
| **lustre-install**            | Installs lustre and zfs packages and dkms modules                                         |
| **drbd**                      | Makes and runs drbd resource                                                              |
| **drbd-install**              | Installs drbd packages and dkms modules                                                   |


[kube-lustre-config.yaml]: https://baltig.infn.it/fornari/kube-lustre/-/blob/master/yaml/kube-lustre-config.yaml

## Requirements

* **Kubernetes:** >=1.9.1 version
* **Servers:** Centos 7 with latest updates and kernel-headers
* **Clients:** Centos 7 with latest updates and kernel-headers (or installed `lustre` kernel-module)
* **Selinux**: disabled
* **Hostnames**: Each node should reach each other by single hostname
* **Fixed IPs**: Each node should have unchangeable IP-address

You need to understand that all packages will installed directly on your nodes.

## Limitations

* Only ZFS Backend is supported.
* Unmanaged `ldev.conf` file.
* This is just a proof of concept, please don't use it on production!

## Quick Start

* Create namespace, and clusterrolebinding:
```
kubectl create namespace lustre
kubectl create clusterrolebinding --user system:serviceaccount:lustre:default lustre-cluster-admin --clusterrole cluster-admin
```

* Edit configuration:
```
vim kube-lustre-config.yaml
```
* In `configuration.json` you can specify configurations that will be identical for each of your daemons.

    * Option `mountpoint` required only for clients.
    * You can remove drbd section, in this case server will be created without ha-pair.
    * If you have more than one drbd-target per physical server, specify different `device`, `port`.
    * Additionally you can add `protocol` and `syncer_rate` options there.

* In `daemons.json` you can specify four types of daemons, for example:

    * `mgs` - Managment server
    * `mdt3` - Metadata target (index:3)
    * `ost4` - Object storage target (index:4)
    * `mdt0-mgs` - Metadata target (index:0) with managment server 
  
  Only one management server can be specified

* Apply your config:
```
kubectl apply -f kube-lustre-config.yaml
```

* Create job to label nodes and run daemons according to your configuration:
```
kubectl create -f kube-lustre-configurator.yaml
```
