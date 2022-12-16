## LDAP

To generate the `cluster-{test|dev|prod}/auth/bindpassword-sealed.yaml` sealed secret:  
```commandline

## Create secret with dry run
oc create secret generic ldap-secret \
  --from-literal=bindPassword=<secret> \
  -n openshift-config \
  --dry-run=client -o yaml \
  > bindpassword.yaml

## Seal to commit to gitops
kubeseal --controller-name="sealed-secrets" \
  --controller-namespace="sealed-secrets" \
  < bindpassword.yaml -o yaml \
  > bindpassword-sealed.yaml
```

To generate the `cluster-{test|dev|prod}/auth/org-ca-config-map.yaml` 
```commandline
oc create configmap ca-config-map \
  --from-file=ca.crt=/path/to/ca \
  -n openshift-config \
  --dry-run=client -o yaml \
  > org-ca-config-map.yaml
```

## HTPassword

### Creating an HTPasswd file using Linux
To use the HTPasswd identity provider, you must generate a flat file that contains the user names and passwords for your cluster by using htpasswd.

**Prerequisites**  
Have access to the htpasswd utility. On Red Hat Enterprise Linux this is available by installing the httpd-tools package.

**Procedure**  
Create or update your flat file with a user name and hashed password:  


```$ htpasswd -c -B -b </path/to/users.htpasswd> <user_name> <password>```  
The command generates a hashed version of the password.  

*For example:*  

```$ htpasswd -c -B -b users.htpasswd user1 MyPassword!```

*Example output*    

```Adding password for user user1```

**Continue to add or update credentials to the file:**  

```$ htpasswd -B -b </path/to/users.htpasswd> <user_name> <password>```

### Creating an HTPasswd file using Windows  
To use the HTPasswd identity provider, you must generate a flat file that contains the user names and passwords for your cluster by using htpasswd.  

**Prerequisites**   
Have access to htpasswd.exe. This file is included in the \bin directory of many Apache httpd distributions.  

**Procedure**  
Create or update your flat file with a user name and hashed password:  


```> htpasswd.exe -c -B -b <\path\to\users.htpasswd> <user_name> <password>```

The command generates a hashed version of the password.  

*For example:*  


```> htpasswd.exe -c -B -b users.htpasswd user1 MyPassword!```

*Example output*  

```Adding password for user user1```

**Continue to add or update credentials to the file:**  


```> htpasswd.exe -b <\path\to\users.htpasswd> <user_name> <password>```

## Creating the HTPasswd secret  
To use the HTPasswd identity provider, you must define a secret that contains the HTPasswd user file.  

**Prerequisites**  
Create an HTPasswd file.  

**Procedure**  
Create a Secret locally that contains the HTPasswd users file:  
```$ oc create secret generic htpass-secret --from-file=htpasswd=<path_to_users.htpasswd> -n openshift-config --dry-run=client -o yaml > htpass-secret.yaml``` 


The secret key containing the users file for the --from-file argument must be named htpasswd, as shown in the above command.   

Create a sealed secret from the htpass-secret to be abe to commit it to GitOps:   
```kubeseal --controller-name="sealed-secrets" --controller-namespace="sealed-secrets"  < "htpass-secret.yaml" -o yaml > htpass-secret-sealed.yaml```

The resulting sealed-secret is safe to commit to GitOps to be applied by ArgoCD.  

You can alternatively apply the following YAML to create the secret:  
```
apiVersion: v1
kind: Secret
metadata:
  name: htpass-secret
  namespace: openshift-config
type: Opaque
data:
  htpasswd: <base64_encoded_htpasswd_file_contents>
```

*Sample HTPasswd CR*  
The following custom resource (CR) shows the parameters and acceptable values for an HTPasswd identity provider.  

*HTPasswd CR*  

```
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: my_htpasswd_provider 
    mappingMethod: claim 
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret 
```

## HTPassword IDP based on  
https://docs.openshift.com/container-platform/4.9/authentication/identity_providers/configuring-htpasswd-identity-provider.html    
