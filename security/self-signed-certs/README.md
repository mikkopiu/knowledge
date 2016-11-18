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
4. **IMPORTANT!** At least update the row `dir` and match it to your current directory, and preferably update the defaults
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
