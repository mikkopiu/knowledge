# Amazon Web Services (AWS)

Some random notes and guides for AWS.

## Route 53 (DNS)

- Can buy / register domains
- Can manage DNS record sets

### Subdomains for nginx-proxy

See [auto-proxy](../docker/auto-proxy)

1. Buy new domain
  - Route 53 will automatically create `SOA` and `NS` records for this domain
2. Create a `A` record pointing your root domain to your IP, e.g.: `domain.com  A  192.168.1.1`
  - Use `CNAME` if your server already has a name
3. **OPTIONAL:** Create a `CNAME` record pointing `www.domain.com` to your root domain, e.g. `www.domain.com  CNAME  domain.com`
4. Create a wildcard subdomain record by adding a `A` record: `*.domain.com  A ALIAS  domain.com`
5. **OPTIONAL**: Create specific subdomains by creating new `A` records: `sub.domain.com  A  ALIAS domain.com`
6. In a few minutes (and possibly after flushing your local DNS; Windows seems to be slow to update DNS records)
    you should be able to access your new subdomain (assuming you've set up a webserver with a virtual host pointing to your subdomain).
