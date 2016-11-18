#!/bin/sh

set -o xtrace errexit nounset

: "${SERVER_NAME:?SERVER_NAME missing! Usage: \"SERVER_NAME=my-server sh createAllCerts.sh\"}"

sh createRootCA.sh
sh createIntermediateCA.sh
sh createServerCert.sh

echo 'All done!'
