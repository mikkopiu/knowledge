#!/bin/sh

set -o xtrace errexit

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

# Generate the private key
cd ..
openssl genrsa -aes256 -out intermediate/private/intermediateCA.key.pem 4096
chmod 400 intermediate/private/intermediateCA.key.pem 

# Create a new CSR
openssl req -config intermediate/openssl.cnf -new -sha256 -key intermediate/private/intermediateCA.key.pem -out intermediate/csr/intermediateCA.csr.pem

# Then sign a certificate with that CSR
openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 1825 -notext -md sha256 -in intermediate/csr/intermediateCA.csr.pem -out intermediate/certs/intermediateCA.cert.pem
chmod 444 intermediate/certs/intermediateCA.cert.pem

# Verify the files
openssl verify -CAfile certs/CA.cert.pem intermediate/certs/intermediateCA.cert.pem
openssl req -text -noout -verify -in intermediate/csr/intermediateCA.csr
openssl rsa -in intermediate/private/intermediateCA.key.pem -check

# Finally, create a certificate chain file
cat intermediate/certs/intermediateCA.cert.pem certs/CA.cert.pem > intermediate/certs/CA-chain.cert.pem
chmod 444 intermediate/certs/CA-chain.cert.pem

echo 'Done'
