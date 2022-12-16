# openshift4-post-install
Post-install ansible playbooks and scripts for either UPI or IPI installations.  

## Prerequisites:

1. A readonly DeployKey (SSH key pair) for the gitops repo `ocp-infra` with the private key  
   saved in `${SECRETS_DIR}` as `gitops-operator`
2. A PFX format certificate for api and apps endpoints named `STAR.apps.cp.{cluster}.{company}.{domain}-2022.pfx`  
   saved in `${SECRETS_DIR}`
3. An LDAP credential for `auth` operator saved as a regular k8s secret manifest called `ldap.yaml` in `${SECRETS_DIR}`
4. An LDAP credential for `group-sync` operator saved as a regular k8s secret manifest called `group-sync-secret.yaml`  
   in `${SECRETS_DIR}`
5. The gitops folder for target env setup in the `ocp-infra` git repo

## Usage:

### Step 1: Install and configure ArgoCD
Once you have your gitops repo created, you can install Argo CD on your cluster with the `openshift-install-gitops` playbook.   

This playbook installs ArgoCD on your cluster, and installs an app_of_apps Application in your cluster pointing to your  
target environment in gitops repo.  

Before running the playbook, copy the gitops.example vars file to gitops, and configure the variables for your setup.  

You can then run the playbook. To run the playbook, run:  
```commandline
ansible-playbook openshift-install-gitops.yaml
```

Argo is now installed, and will be self managing via the configuration in `ocp-infra/base/argocd`  
if the gitops env already exists for the current target cluster.  

For a net new install where no existing gitops repo exists you can bring the ArgoCD  
configuration into GitOps, take the `argocd` folder from `gitops-manifests/` and upload it to   
your gitops repository, and point to the new `argocd` directory from your appofapps folder.  

This `argocd` folder contains the manifests that the Ansible playbook used to install ArgoCD, and by also adding these  
manifests to GitOps, you ensure that the configuration for your ArgoCD installation doesn't  
drift from your git definitions.  

### Step 2: Check that ArgoCD is healthy and has started syncing `ocp-infra/cluster-{test|dev|prod}` to your cluster

Once ArgoCD and the appofapps is deployed, ArgoCD will begin syncing all of the applications from the target gitops  
folder into the cluster, if it is a rebuild of a preexisting cluster and the original sealedsecrets encryption  
key was not reused then there are some secrets that will need to be resealed and will fail to apply until they are.

For this step most important application that we need to see synced and deployed is SealedSecrets which  
will be found in the `sealed-secrets` namespace. You can check progress of the creation of the sealed-secrets   
controller by running:

```commandline
KUBECONFIG=path_to_kubeconfig oc {get|describe} application sealed-secrets-controller -n openshift-gitops
```

If for any reason argocd is unable to synchronize and install sealed-secrets controller then  
troubleshooting will be required by looking at logs of following pods and investigating further:  

`openshift-gitops/argocd-repo-server-*-*`  
`openshift-gitops/argocd-server-*-*`  
`openshift-gitops/gh-proxy-*-*`  


### Step 3: Install proper `cluster-api` and `ingress` certificates

The HTTPS certificates installed on the cluster when the cluster is first created are temporary certificates that are  
created just to bootstrap the cluster.  

In order to install permanent certificates into the cluster, you can use the  
included `extract-pfx.sh` and `update-cluster-certificates.sh` scripts to create SealedSecret manifests  
with the new certificates, that can then be installed into gitops.  

```commandline
./extract-pfx {test|dev|prod}
./update-cluster-certificates.sh "/srv/stakater/{test|dev|prod}/secrets/"
```

Before you can run the scripts, you must ensure the SealedSecrets operator is installed on the cluster.  
SealedSecrets automatically encrypts/decrypts your secrets using a key stored on your cluster, so that your secrets  
can be managed in git, fully encrypted.  
In order to install SealedSecrets, you should add the SealedSecrets Helm chart or manifest to your GitOps repo.  

The certificates must be in the correct format. They should be PEM files named `cert.pem` and `cert.key`,  
as well as a cert for the CA named `ca-bundle.crt`.  

There is a script called `extract-pfx.sh` that can convert certs from the PFX format to the correct format.  

Once you have SealedSecrets installed and your certs in the correct format,  
you can run the `update-cluster-certificates.sh` script.  

To generate your SealedSecrets manifests, run the script with the path to your certificates as an argument:  
```commandline
KUBECONFIG=path_to_kubeconfig ./update-cluster-certificates.sh ${SECRETS_DIR}
```
As with the ArgoCD installation, the scripts have generated manifests inside the `gitops-manifests/` directory.  
These manifests have not been applied yet, and should be applied with ArgoCD GitOps.  

Repeat this process before your certificates are due to expire.  

### Step 4: Update remaining SealedSecrets in `ocp-infra` 

The following manifests in the `ocp-infra` gitops repo have SealedSecrets that need to be updated after a deployment/rebuild of a cluster:  

```commandline
cluster-${ENV}/apiserver/cluster-api-certificate-default-sealed.yaml
cluster-${ENV}/auth/bindpassword-sealed.yaml
cluster-${ENV}/group-sync-instance/org-ca-secret.yaml
cluster-${ENV}/group-sync-instance/ldap-group-sync-secret-sealed.yaml
cluster-${ENV}/ingress/cluster-ingress-certificate-default-sealed.yaml
```

See the related README's in `base/...` for further details on secret format and seal procedure.  

### Results
If you've done everything correctly, you should have a full Openshift 4 cluster ready to run your 
applications through the ArgoCD git repository!
