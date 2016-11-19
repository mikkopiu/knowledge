#!/bin/sh

set -o xtrace ; set -o errexit

# Assume we are the root certs directory,
# and create the required directories.
cd CA
mkdir -p intermediate/certs intermediate/crl intermediate/csr intermediate/newcerts intermediate/private
cd intermediate/
chmod 700 private

# Create flat file database for signed certificates
touch index.txt
echo 1000 > serial

if [ ! -f ./openssl.cnf ];
then
    echo 'No openssl.cnf found in ./CA/intermediate! Copy the intermediate CA conf there!'
    exit 1
fi

FNAME="intermediateCA"

# Generate the private key
cd ..
openssl genrsa -aes256 -out intermediate/private/$FNAME.key.pem 4096
chmod 400 intermediate/private/$FNAME.key.pem 

# Create a new CSR
openssl req -config intermediate/openssl.cnf -new -sha256 -key intermediate/private/$FNAME.key.pem -out intermediate/csr/$FNAME.csr.pem

# Then sign a certificate with that CSR
openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 1825 -notext -md sha256 -in intermediate/csr/$FNAME.csr.pem -out intermediate/certs/$FNAME.cert.pem
chmod 444 intermediate/certs/$FNAME.cert.pem

# Verify the files
openssl verify -CAfile certs/CA.cert.pem intermediate/certs/$FNAME.cert.pem
openssl req -text -noout -verify -in intermediate/csr/$FNAME.csr.pem
openssl rsa -in intermediate/private/$FNAME.key.pem -check

# Finally, create a certificate chain file
cat intermediate/certs/$FNAME.cert.pem certs/CA.cert.pem > intermediate/certs/CA-chain.cert.pem
chmod 444 intermediate/certs/CA-chain.cert.pem

cd ..
echo 'Done'
