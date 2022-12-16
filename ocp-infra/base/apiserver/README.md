# APIServer

To generate the `cluster-{test|dev|prod}/apiserver/cluster-api-certificate-default-sealed.yaml` sealed secret:  
```commandline
SECRETS_DIR="/srv/stakater/{test|dev|prod}/secrets"
API_CERT_CHAIN_FILE="${SECRETS_DIR}/cert.pem"
API_CERT_KEY_FILE="${SECRETS_DIR}/cert.key"

## Create secret via dryrun
oc create secret tls cluster-api-certificate-default \
  --cert="${API_CERT_CHAIN_FILE}" \
  --key="${API_CERT_KEY_FILE}" \
  -n openshift-config \
  --dry-run=client -o yaml > api-custom-cert.yaml

## Seal to commit to gitops
kubeseal --controller-name="sealed-secrets" \
  --controller-namespace="sealed-secrets" \
  < api-custom-cert.yaml \
  -o yaml > cluster-api-certificate-default-sealed.yaml
```

To extract `cert.pem` and `cert.key` from a pfx file see [extract-pfx.sh](ocp-bootstrap/post-install/extract-pfx.sh) 
