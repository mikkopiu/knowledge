#!/bin/sh

sh ./genCert.sh
mv ./certs/* /etc/nginx/certs/

cd /app/
exec /app/docker-entrypoint.sh forego start -r
