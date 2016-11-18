# Self-signed SSL certificates

## Info

Heavily based on these wonderful instructions: https://jamielinux.com/docs/openssl-certificate-authority/index.html

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
