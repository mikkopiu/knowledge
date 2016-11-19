#!/bin/sh

set -o xtrace ; set -o errexit

# Create CA directories
# and set necessary file permissions.
mkdir -p CA/certs CA/crl CA/newcerts CA/private
cd CA
chmod 700 private

# Create a flat file database for signed certificates
touch index.txt
echo 1000 > serial

if [ ! -f ./openssl.cnf ];
then
    echo 'openssl.cnf is missing, please add it in the CA directory'
    exit 1
fi

# Generate a private key,
# and make sure it is set to read-only and for only the current user.
openssl genrsa -aes256 -out private/CA.key.pem 4096
chmod 400 private/CA.key.pem

# Create the actual certificate, see README for more info
openssl req -config openssl.cnf -key private/CA.key.pem -new -x509 -days 3650 -sha256 -extensions v3_ca -out certs/CA.cert.pem
chmod 444 certs/CA.cert.pem

cd ..
echo 'Done'
