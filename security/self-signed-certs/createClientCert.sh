#!/bin/sh
set -o xtrace ; set -o errexit ; set -o nounset

: "${CLIENT_NAME:?CLIENT_NAME missing! Usage: \"CLIENT_NAME=my-client sh createClientCert.sh\"}"

# Assume we are in the root certificate directory
echo "Creating directory user/${CLIENT_NAME}"
mkdir user/${CLIENT_NAME}

echo "Generating private key"
openssl genrsa -aes256 -out user/${CLIENT_NAME}/${CLIENT_NAME}.key.pem 2048
chmod 400 user/${CLIENT_NAME}/${CLIENT_NAME}.key.pem

echo "Generating a Certificate Signing Request"
openssl req -config CA/intermediate/openssl.cnf -key user/${CLIENT_NAME}/${CLIENT_NAME}.key.pem -new -sha256 -out user/${CLIENT_NAME}/${CLIENT_NAME}.csr.pem

echo "Generating certificate file"
openssl ca -config CA/intermediate/openssl.cnf -extensions usr_cert -days 730 -notext -md sha256 -in user/${CLIENT_NAME}/${CLIENT_NAME}.csr.pem -out user/${CLIENT_NAME}/${CLIENT_NAME}.cert.pem
chmod 444 user/${CLIENT_NAME}/${CLIENT_NAME}.cert.pem

echo "Generating P12-file for Chrome installation"
openssl pkcs12 -export -clcerts -in user/${CLIENT_NAME}/${CLIENT_NAME}.cert.pem -inkey user/${CLIENT_NAME}/${CLIENT_NAME}.key.pem -out user/${CLIENT_NAME}/${CLIENT_NAME}.p12

echo "Done"
