# Self-signed SSL certificates

**NOTE: You should not take this as some end-all best practices guide! Instead, familiarize yourself with the subject before actually following any advice given here. All of this information is based on my personal knowledge at the time of writing.**

Heavily based on these wonderful instructions: https://jamielinux.com/docs/openssl-certificate-authority/index.html

You should also check out this wiki-page by Mozilla on Server Side TLS: https://wiki.mozilla.org/Security/Server_Side_TLS

## Info

Root CA is the one you should add as your trusted Root CA in e.g. your browser.

One level below the Root CA, is the Intermediate CA. This certificate is the one used to sign all server and user certificates. You can add this certificate as a trusted intermediate authority to your browser, but it is usually not necessary, as long as the final authority (i.e. Root CA) is trusted by your browser.

Servers should have their own server certificates for HTTPS-connections, that are signed by the Intermediate CA. These certificates cannot and should not be used to sign any further certificates.

Client certificates can be created for users that need automatic client authentication. Client certificates are signed by the Intermediate CA.

Basic structure of the generated certificates:
```
                 +-----------+
                 |  Root CA  |
                 +-----------+
                       |
                       |
          +------------v-------------+
      +---+     Intermediate CA      +--+
      |   +--------------------------+  |
      |                                 |
      |                                 |
+-----v---------+         +-------------v-----+
|    Servers    |         |       Users       |
+---------------+         +-------------------+
|               |         |                   |
|    ServerA    |         |       UserA       |
|               |         |                   |
|     ...       |         |      ...          |
+---------------+         +-------------------+
```

### Directory structure

```shell
[me@machine dir]$ ls -lR
.:
drwxr-xr-x. 7 me me 4096 31.5. 16:21 CA        <== Root CA & Intermediate CA
drwxr-xr-x. 2 me me 4096 31.5. 16:07 server    <== Server certs
drwxr-xr-x. 6 me me   89 31.5. 11:17 user      <== User certs
```

## Creating a unsecure server certificate

### Notes

**This method is not recommended for any serious use, as it strips out the pass phrase from the private key and does not use any Certificate Authority, removing your ability to revoke the certificate!**

Only use this for things like testing HTTPS on your demo web server. Or if your really know what you are doing, update the script to not remove the pass phrase and pass it to your web server in some secure manner.

### Steps

#### By script

```shell
./createSimplifiedServerCert.sh
```

and follow any instructions given. **Remember to set a valid Common Name (e.g. matching the address you will be connecting to your web server).**

## Creating a Root Certificate Authority (CA)

### Notes

The root certificate will be signed to be valid until 2026 (i.e. for 10 years), and when it needs to be renewed,
you should only have to create a new certificate file by signing it with the existing private key.

As this is the topmost trusted certificate in the chain, it should have proper security.
That's why the private key is so large (4096 bits).
It also uses AES256 for its encryption.
**Preferably, you should create this certificate in some air-gapped machine or something similar.**

### With scripts

1. Create a new directory in a secure machine where you want to store your Root CA certificate
2. Copy `createRootCA.sh` into that directory
3. Create a sub-directory `CA` and copy `openssl.cnf` under that
4. **IMPORTANT!** Update at least the row `dir` and match it to your current directory, and preferably update the defaults
5. Run `./createRootCA.sh` and follow any instructions given
6. **Done!**

### Manually

Create necessary folders:
```
[me@machine dir]# mkdir CA
[me@machine dir]# cd CA/
[me@machine CA]# mkdir certs crl newcerts private
[me@machine CA]# chmod 700 private
```

The `index.txt` and `serial` files act as a flat file database to keep track of signed certificates.
```
[me@machine CA]# touch index.txt
[me@machine CA]# echo 1000 > serial
```

Copy `openssl.cnf` to `CA` from this repo and update the default values for Country Names, Locations and directories.

Generate a private key:
```
[me@machine CA]# openssl genrsa -aes256 -out private/CA.key.pem 4096
[me@machine CA]# chmod 400 private/CA.key.pem 
```

Next, create the actual certificate and sign it with the created private key.
`-days` sets the amount of days the certificate will be valid, here we set it to 3650 (~10 years).
`-extensions` sets the extension definition to use from the configuration file;
here we give this certificate the rights to sign certificates, i.e. CA extensions.
**NOTE:** `[string]` shows the default value for a field, if left empty, like below.
```
[me@machine CA]# openssl req -config openssl.cnf -key private/CA.key.pem -new -x509 -days 3650 -sha256 -extensions v3_ca -out certs/CA.cert.pem
Country Name (2 letter code) [FI]:
State or Province Name [Uusimaa]:
Locality Name [Helsinki]:
Organization Name [MyOrganisation]:
Organizational Unit Name [MyUnit]:
Common Name []:MyOrganisation Root CA
Email Address []:
[me@machine CA]# chmod 444 certs/CA.cert.pem
```

The certificate should be able to be read by anyone, but not written over by anyone, hence `chmod 444`.

## Intermediate Certificate Authority

### Creating an Intermediate Certificate Authority

#### Steps

##### With scripts

1. Copy `createIntermediateCA.sh` into the same certificate directory you copied the previous script
2. Create a sub-directory `CA/intermediate` and copy `openssl.intermediate.cnf` as `openssl.cnf` under that
3. **IMPORTANT!** Update at least the row `dir` and match it to your current directory, and preferably update the defaults
4. Run `./createIntermediateCA.sh` and follow any instructions given
5. **Done!**

##### Manually method

Create a directory for the intermediate CA under the directory you created for the Root CA, and create the database files like with the Root CA:
```
[me@machine CA]# mkdir intermediate
[me@machine CA]# cd intermediate/
[me@machine intermediate]# mkdir certs crl csr newcerts private
[me@machine intermediate]# chmod 700 private
[me@machine intermediate]# touch index.txt
[me@machine intermediate]# echo 1000 > serial
```

Next create another `openssl.cnf` file under the current directory (`intermediate`).

Generate a private key for the intermediate CA, again with decent security as this key is mostly used to sign things => no performance loss anywhere:
```
[me@machine intermediate]# cd ..
[me@machine CA]# openssl genrsa -aes256 -out intermediate/private/intermediateCA.key.pem 4096
[me@machine CA]# chmod 400 intermediate/private/intermediateCA.key.pem 
```

Create a Certificate Signing Request (CSR) with the new private key:

**NOTE:** Common Name here is "MyOrganisation Intermediate CA".
```
[me@machine CA]# openssl req -config intermediate/openssl.cnf -new -sha256 -key intermediate/private/intermediateCA.key.pem -out intermediate/csr/intermediateCA.csr.pem
Country Name (2 letter code) [FI]:
State or Province Name [Uusimaa]:
Locality Name [Helsinki]:
Organization Name [MyOrganisation]:
Organizational Unit Name [MyUnit]:
Common Name []:MyOrganisation Intermediate CA
Email Address []:
```

The signing request can then be used to create the actual certificate for the intermediate CA.
**NOTE:** You should now be in the `CA` directory to reference the *Root CA's* configuration file
instead of the intermediate one (the configuration sets the intermediate certificate to be signed by &
added to the Root CA's certificate database). The `-extensions v3_intermediate_ca` gives this certificate slightly less rights
than the Root CA (see the configuration file for more info).
```
[me@machine CA]# openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 1825 -notext -md sha256 -in intermediate/csr/intermediateCA.csr.pem -out intermediate/certs/intermediateCA.cert.pem
[me@machine CA]# chmod 444 intermediate/certs/intermediateCA.cert.pem 
```

You can the verify that you have a working certificate, CSR and keys with:
```
openssl verify -CAfile certs/CA.cert.pem intermediate/certs/intermediateCA.cert.pem
openssl req -text -noout -verify -in intermediate/csr/intermediateCA.csr.pem
openssl rsa -in intermediate/private/intermediateCA.key.pem -check
```

Finally, you should create a certificate chain file that, as the name suggests, contains the Root CA and the Intermediate CA certificates. This file is then given to e.g. Apache to use as the CA certificate.
```
[me@machine CA]# cat intermediate/certs/intermediateCA.cert.pem certs/CA.cert.pem > intermediate/certs/CA-chain.cert.pem
[me@machine CA]# chmod 444 intermediate/certs/CA-chain.cert.pem 
```

### Revoking an Intermediate Certificate

**WARNING!** Revoking a certificate is final! You should only do this if you are certain the certificate (or certificates signed with it) is at risk or is no longer valid.

#### Manual method (generalized)

1. Locate your OpenSSL configuration file (or refer to OpenSSL's manual to set all necessary options for revoking a certificate from a CA)
2. Locate the intermediate CA's certificate you want to revoke
3. Run `openssl ca -config my-openssl.cnf -revoke my-Intermediate.cert.pem`

## Server certificates

### Creating a server certificate

#### Notes

These certificates are the lowest level certificates along user certificates.
These certificates cannot be used to further sign any new certificates and should only be used to identify servers
as trusted by their Certificate Authorities, here MyOrganisation Intermediate CA (and Root CA).
These are also the ones given to your web server (e.g. Apache) to use as its server certificate, enabling HTTPS connections.

#### Steps

##### With scripts

1. Copy `createServerCert.sh` into the same certificate directory you copied the previous scripts
2. Run `SERVER_NAME=my-server sh createServerCert.sh` and follow any instructions given
  - The Common Name for the server certificate must match the address that is used to connect to the server (e.g. its domain name or IP)
3. **Done!**

You are now ready to install the certificate into your server.

##### Manually

Private keys:
```
[me@machine CA]# openssl genrsa -aes256 -out intermediate/private/myServer.key.pem 2048
[me@machine CA]# chmod 400 intermediate/private/myServer.key.pem 
```

CSR:
```
[me@machine CA]# openssl req -config intermediate/openssl.cnf -key intermediate/private/myServer.key.pem -new -sha256 -out intermediate/csr/myServer.csr.pem
```

Certificate:
```
[me@machine CA]# openssl ca -config intermediate/openssl.cnf -extensions server_cert -days 730 -notext -md sha256 -in intermediate/csr/myServer.csr.pem -out intermediate/certs/myServer.cert.pem
Country Name (2 letter code) [FI]:
State or Province Name [Uusimaa]:
Locality Name [Helsinki]:
Organization Name [MyOrganisation]:
Organizational Unit Name [MyUnit]:
Common Name []:172.21.169.245
Email Address []:

[me@machine CA]# chmod 444 intermediate/certs/myServer.cert.pem 
```

Verify (with the CA chain file):
```
[me@machine CA]# openssl verify -CAfile intermediate/certs/CA-chain.cert.pem intermediate/certs/myServer.cert.pem 
intermediate/certs/myServer.cert.pem: OK
```

### Revoking a server certificate

#### Manual method (general)

1. Locate the OpenSSL configuration file for your CA (or refer to OpenSSL documentation for the necessary options)
2. Locate the certificate you want to revoke
3. Run `openssl  ca -config path/to/openssl.cnf -revoke /path/to/file`
4. You can now rename/delete the old certificate file

## User certificates

### Creating a new user certificate

#### Notes

These certificates are used to authenticate users and applications into servers that trust the Root CA (e.g. Apache).

#### With scripts


1. Copy `createClientCert.sh` into the same certificate directory you copied the previous scripts
2. Run `CLIENT_NAME=my-client sh createClientCert.sh` and follow any instructions given
  - Set a descriptive Common Name (e.g. User Alpha Beta xyz123)
  - Leave email, challenge password and optional company fields empty for the CSR, unless required
3. **Done!**

#### Manually

1. Private key: `openssl genrsa -aes256 -out user/my-client/my-client.key.pem 2048` & `chmod 400 user/my-client/my-client.key.pem`
2. CSR: `openssl req -config CA/intermediate/openssl.cnf -key user/my-client/my-client.key.pem -new -sha256 -out user/my-client/my-client.csr.pem`
3. Certificate: `openssl ca -config intermediate/openssl.cnf -extensions usr_cert -days 730 -notext -md sha256 -in user/my-client/my-client.csr.pem -out user/my-client/my-client.cert.pem` & `chmod 444 user/my-client/my-client.cert.pem`
4. Verify: `openssl verify -CAfile CA/intermediate/certs/CA-chain.cert.pem user/my-client/my-client.cert.pem`
5. Optionally, create a P12 file for Chrome & Firefox installation: `openssl pkcs12 -export -clcerts -in user/my-client/my-client.cert.pem -inkey user/my-client/my-client.key.pem -out user/my-client/my-client.p12`

### Revoking a user certificate

Refer to the instructions for revoking server certificates: [Revoking a server certificate](Server-certificates#revoking-a-server-certificate)
