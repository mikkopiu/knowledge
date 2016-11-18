#!/bin/sh

set -o xtrace errexit nounset

: "${SERVER_NAME:?SERVER_NAME missing! Usage: \"SERVER_NAME=my-server sh createServerCert.sh\"}"

echo "Generating private key"
openssl genrsa -aes256 -out server/${SERVER_NAME}.key.pem 2048
chmod 400 server/${SERVER_NAME}.key.pem

echo "Generating a Certificate Signing Request (set the Common Name to match the server's IP or other name used to connect to it)"
openssl req -config saviCA/intermediate/openssl.cnf -key server/${SERVER_NAME}.key.pem -new -sha256 -out server/${SERVER_NAME}.csr.pem

echo "Generating certificate file"
openssl ca -config saviCA/intermediate/openssl.cnf -extensions server_cert -days 730 -notext -md sha256 -in server/${SERVER_NAME}.csr.pem -out awecwe/${SERVER_NAME}.cert.pem
chmod 444 server/${SERVER_NAME}.cert.pem

echo "Done"