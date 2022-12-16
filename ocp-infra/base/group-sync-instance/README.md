## Group-Sync operator

To generate the `cluster-{test|dev|prod}/group-sync-instance/ldap-group-sync-secret-sealed.yaml` sealed secret:  
```commandline

## Create secret with dry run
oc create secret generic ldap-group-sync \
  --from-literal=username=<username> \
  --from-literal=password=<password> \
  --dry-run=client -o yaml \
  > ldap-group-sync-secret.yaml

## Seal to commit to gitops
kubeseal --controller-name="sealed-secrets" \
  --controller-namespace="sealed-secrets" \
  < ldap-group-sync-secret.yaml -o yaml \
  > ldap-group-sync-secret-sealed.yaml
```

To generate the `cluster-{test|dev|prod}/group-sync-instance/org-ca-secret.yaml` 
```commandline
oc create secret generic org-ca-secret \
  --from-file=ca.crt=<file> \
  --dry-run=client -o yaml \
  > org-ca-secret.yaml
```
