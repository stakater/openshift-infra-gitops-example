# Extra notes:

## LDAP auth
bind secret and LDAP ca configmap need to be prepared in advance and sealed with sealed secrets

### Raw secrets
`ocp create secret --dry-run=client -o yaml generic ldap-secret -n openshift-config --from-literal=bindPassword=foo > ldap.yaml`
`ocp create secret --dry-run=client -o yaml generic ldap-group-sync -n group-sync-operator --from-literal=username=foo --from-literal=password=bar > group-sync-secret.yaml`
username in `ldap-group-sync` should be full path to the bind user, example:
```
CN=Service Account LDAP OpenShift,OU=Service Accounts,OU=Administration,DC=some,DC=company,DC=com
```

### Sealing
`kubeseal -o yaml --controller-name="sealed-secrets" --controller-namespace="sealed-secrets"  < ldap.yaml" > gitops-manifests/ldap-sealed.yaml`
`kubeseal -o yaml --controller-name="sealed-secrets" --controller-namespace="sealed-secrets"  < group-sync-secret.yaml" > gitops-manifests/group-sync-secret.yaml`
