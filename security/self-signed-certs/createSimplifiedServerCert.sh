#!/bin/sh

set -o errexit

VALID_FOR_DAYS="${VALID_FOR_DAYS:-365}"

echo 'Creating a directory to store the certificate files'
CERT_DIR="generated-certs"
CERT_FNAME="$CERT_DIR/serverCert"
mkdir -p $CERT_DIR

echo 'Generating a private key'
openssl genrsa -aes256 -out $CERT_FNAME.key.pem 2048

echo 'Stripping out passphrase from key for nginx (DO NOT DO THIS IN ANY REAL ENVIRONMENT!)'
cp $CERT_FNAME.key.pem $CERT_FNAME.key.pem.orig
openssl rsa -in $CERT_FNAME.key.pem.orig -out $CERT_FNAME.key.pem
chmod 400 $CERT_FNAME.key.pem*

echo 'Generating a Certificate Signing Request'
openssl req -new -sha256 -key $CERT_FNAME.key.pem -out $CERT_FNAME.csr $EXTRA_REQ_OPTS

echo 'Generating the actual certificate'
openssl x509 -req -days "$VALID_FOR_DAYS" -in $CERT_FNAME.csr -signkey $CERT_FNAME.key.pem -out $CERT_FNAME.crt

echo "Generated certificate in $CERT_DIR"

printf "+==========================================
+ SSL Certificate created
+
+ Copy the files in $CERT_DIR into your desired path,
+ e.g. for nginx it might be: /etc/nginx/ssl and
+ use it like this in your nginx config:
+==========================================\n\n
ssl_certificate		/path/to/certs/$CERT_FNAME.crt
ssl_certificate_key	/path/to/certs/$CERT_FNAME.key.pem
\n\n"

echo 'Done'
