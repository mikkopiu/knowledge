#!/bin/sh

set -o xtrace errexit nounset

: "${SERVER_NAME:?SERVER_NAME missing! Usage: \"SERVER_NAME=my-server sh createAllCerts.sh\"}"

mkdir -p CA/intermediate
cp openssl.cnf CA/
cp openssl.intermediate.cnf CA/intermediate/openssl.cnf

sh createRootCA.sh
sh createIntermediateCA.sh
sh createServerCert.sh

echo 'All done!'
