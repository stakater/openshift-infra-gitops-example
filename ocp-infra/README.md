# Openshift infrastructure gitops example 

This repo provides a basic example for multicluster gitops with ArgoCD on OpenShift

`base/` contains shared config that is common to all clusters and provides sane defaults

`cluster-dev` and the other "cluster specific" directories contain only the overlays for overwriting the defaults specific for the target cluster 
