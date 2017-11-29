# Amazon Web Services (AWS)

Some random notes and guides for AWS.

## CloudFormation

### Templates

Collection of my templates: https://github.com/mikkopiu/aws-cf-templates
Great infrastructure templates: https://github.com/stelligent/cloudformation_templates
Official sample templates: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/sample-templates-services-eu-central-1.html

### Tools

- cfn_nag: https://github.com/stelligent/cfn_nag
  - Scan for insecure patterns in CloudFormation templates, easy to integrate into CI/CD pipelines:
  
      ```sh
      cfn-nag --print-suppression --input-path mytemplate.yaml
      ```

## EC2

### Provision simple Docker host

1. Create new Ubuntu 16.04 instance
2. Log in
3. Run `./provision-simple-docker.sh`
4. Reboot & done

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
