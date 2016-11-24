#!/bin/sh

set -o errexit

echo 'Creating a directory to store the certificate files'
CERT_DIR="certs"
CERT_FNAME="$CERT_DIR/$CERT_VIRTUAL_HOST"
mkdir -p $CERT_DIR

openssl req -x509 -nodes -newkey rsa:2048 -keyout $CERT_FNAME.key -days 365 -passin env:CERT_PASSWORD -subj "$CERT_SUBJ" -out $CERT_FNAME.crt
chmod go-rwx $CERT_FNAME.key

echo "Generated certificate in $CERT_DIR"

printf "+==========================================
+ SSL Certificate created
+
+ Copy the files in $CERT_DIR into your desired path,
+ e.g. for nginx it might be: /etc/nginx/ssl and
+ use it like this in your nginx config:
+==========================================\n\n
ssl_certificate		/path/to/certs/$CERT_FNAME.crt
ssl_certificate_key	/path/to/certs/$CERT_FNAME.key
\n\n"

echo 'Done'
