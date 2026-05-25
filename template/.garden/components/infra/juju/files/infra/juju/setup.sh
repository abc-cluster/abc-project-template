#!/usr/bin/env sh


#Install MicroK8s:
sudo snap install microk8s --classic

#Enable required MicroK8s addons:
microk8s enable dns storage ingress

#Bootstrap Juju to MicroK8s:
juju bootstrap microk8s micro

#Deploy MinIO with the bundle:
juju deploy ./infra/minio-microk8s-bundle.yaml
