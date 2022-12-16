## Create a sealed secret from the Kubeseal cli  

**Prerequisites**  
The latest version of `kubeseal` which can be found on the [releases page in github](https://github.com/bitnami-labs/sealed-secrets/releases)  

**Procedure**  

***Example based on htpassword secret for auth***  
Create a Secret locally that contains the HTPasswd users file:  
```$ oc create secret generic htpass-secret --from-file=htpasswd=<path_to_users.htpasswd> -n openshift-config --dry-run=client -o yaml > htpass-secret.yaml``` 

Create a sealed secret from the htpass-secret to be able to commit it to GitOps:   
```kubeseal --controller-name="sealed-secrets" --controller-namespace="sealed-secrets"  < "htpass-secret.yaml" -o yaml > htpass-secret-sealed.yaml```

The resulting sealed-secret is safe to commit to GitOps to be applied by ArgoCD.  

See [sealed-secrets](https://github.com/bitnami-labs/sealed-secrets) github repo for further information
