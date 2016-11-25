# Amazon Web Services (AWS)

Some random notes and guides for AWS.

## Route 53 (DNS)

- Can buy / register domains
- Can manage DNS record sets

### Create a domain through Route 53

1. Buy new domain
  - Route 53 will automatically create `SOA` and `NS` records for this domain
2. Create a `A` record for your domain name, e.g.: `domain.com  A  192.168.1.1`
  - Replace with your domain name and server IP/name
3. **Done**
4. **OPTIONAL**: Create a subdomain by creating a new `A` record set: `registry.domain.com  A  ALIAS domain.com`
  - In a few minutes (and possibly after flushing your local DNS; Windows seems to be slow to update DNS records)
    you should be able to access your new subdomain (assuming you've set up a webserver with a virtual host pointing to your subdomain).
