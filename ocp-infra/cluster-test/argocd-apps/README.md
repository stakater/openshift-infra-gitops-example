This is an ArgoCD Application that defines all of our `Application` CRs. (App of apps pattern.)

The `Application` CR that points to this directory is installed directly into the cluster by the post-install playbook, 
and should have the name `Application/appofapps` in the `openshift-gitops` namespace.
