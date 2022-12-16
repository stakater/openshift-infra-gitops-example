#!/bin/bash

# Usage: ./extract-pfx {test|dev|prod}
CLUSTER_ENV="${1}"
SECRETS_DIR="/srv/stakater/${CLUSTER_ENV}/secrets/"
NAME="STAR.apps.cp.${CLUSTER_ENV}.org.no-2022"
KEY="${NAME}.key"
KEY_DECRYPTED="cert.key"
CA="ca-bundle.crt"
CERT="${NAME}.crt"
openssl pkcs12 -in "${SECRETS_DIR}/${NAME}.pfx" -nocerts -nodes | sed -ne '/-BEGIN PRIVATE KEY-/,/-END PRIVATE KEY-/p' > "${SECRETS_DIR}/${KEY}"
openssl pkcs12 -in "${SECRETS_DIR}/${NAME}.pfx" -clcerts -nokeys | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "${SECRETS_DIR}/${CERT}"
openssl pkcs12 -in "${SECRETS_DIR}/${NAME}.pfx" -cacerts -nokeys -chain | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "${SECRETS_DIR}/${CA}"

openssl rsa -in "${SECRETS_DIR}/${KEY}" -out ${SECRETS_DIR}/${KEY_DECRYPTED}

cat "${SECRETS_DIR}/${CERT}" "${SECRETS_DIR}/${CA}" "${SECRETS_DIR}/${KEY}" > "${SECRETS_DIR}/cert.pem"
