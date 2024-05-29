#!/bin/bash
R_IMAGE=rtest

docker build R -t $R_IMAGE
docker save $R_IMAGE > r.tar
microk8s ctr image import r.tar

kubectl delete -n default pod rapp --force || echo "Nothing to delete"
kubectl apply -f R/pod.yaml
