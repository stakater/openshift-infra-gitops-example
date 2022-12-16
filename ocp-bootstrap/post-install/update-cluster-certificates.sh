#!/bin/bash
set +x
set -e

# Usage: ./update-cluster-certificates {path to certs folder}
# Certs must be in PEM format

SECRETS_DIR="$1"
SEALED_SECRETS_NS="${SEALED_SECRETS_NS:-sealed-secrets}"
SEALED_SECRETS_CONTROLLER="${SEALED_SECRETS_CONTROLLER:-sealed-secrets}"

API_CERT_CHAIN_FILE="${SECRETS_DIR}/cert.pem"
API_CERT_KEY_FILE="${SECRETS_DIR}/cert.key"

INGRESS_CERT_BUNDLE_FILE="${SECRETS_DIR}/ca-bundle.crt"
INGRESS_CERT_FILE="${SECRETS_DIR}/cert.pem"
INGRESS_CERT_KEY_FILE="${SECRETS_DIR}/cert.key"

# API Certificates
## Generate Certificate secret
echo "Generating apiserver sealedsecret"
oc --insecure-skip-tls-verify create secret tls cluster-api-certificate-default --cert="${API_CERT_CHAIN_FILE}" --key="${API_CERT_KEY_FILE}" -n openshift-config --dry-run=client -o yaml > "${SECRETS_DIR}/api-custom-cert.yaml"

## Seal Certificate
kubeseal --insecure-skip-tls-verify --controller-name="${SEALED_SECRETS_CONTROLLER}" --controller-namespace="${SEALED_SECRETS_NS}"  < "${SECRETS_DIR}/api-custom-cert.yaml" -o yaml > gitops-manifests/cluster-api-certificate-default-sealed.yaml

# INGRESS Certificates
# Generate CUSTOM CA configmap
echo "Generating apiserver ca configmap"
oc --insecure-skip-tls-verify create configmap custom-ca --from-file=ca-bundle.crt="${INGRESS_CERT_BUNDLE_FILE}" -n openshift-config --dry-run=client -o yaml > gitops-manifests/ingress-custom-ca.yaml

## Generate Ingress TLS certificate secret
echo "Generating ingress sealedsecret"
oc --insecure-skip-tls-verify create secret tls cluster-ingress-certificate-default --cert="${INGRESS_CERT_FILE}" --key="${INGRESS_CERT_KEY_FILE}" -n openshift-ingress --dry-run=client -o yaml > "${SECRETS_DIR}/ingress-tls-cert.yaml"

## Seal Certificate
kubeseal --insecure-skip-tls-verify --controller-name="${SEALED_SECRETS_CONTROLLER}" --controller-namespace="${SEALED_SECRETS_NS}"  < "${SECRETS_DIR}/ingress-tls-cert.yaml" -o yaml > gitops-manifests/cluster-ingress-certificate-default-sealed.yaml

echo "Make sure to commit the secrets in gitops-manifests/ into your gitops repo!"


# If the LDAP secrets are prepared you can uncomment these lines to also seal them
#kubeseal --insecure-skip-tls-verify --controller-name="${SEALED_SECRETS_CONTROLLER}" --controller-namespace="${SEALED_SECRETS_CONTROLLER}"  < "${SECRETS_DIR}/ldap.yaml" -o yaml > gitops-manifests/ldap-sealed.yaml
#kubeseal --insecure-skip-tls-verify --controller-name="${SEALED_SECRETS_CONTROLLER}" --controller-namespace="${SEALED_SECRETS_CONTROLLER}"  < "${SECRETS_DIR}/group-sync-secret.yaml" -o yaml > gitops-manifests/group-sync-secret.yaml
