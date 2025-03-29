# Amazon Web Services (AWS)

Some random notes and guides for AWS.

## MFA and aws-vault

1. Install [aws-vault](https://github.com/99designs/aws-vault)
1. Configure like below to user aws-vault as transparently as possible (or as transparently as I know):

`~/.zshrc`:

```sh
# aws-vault shell completion
eval "$(aws-vault --completion-script-zsh)"

# aws-vault config
export AWS_VAULT_BACKEND=secret-service
export AWS_VAULT_PROMPT=zenity
# or "ykman" + YKMAN_OATH_CREDENTIAL_NAME='<arn of mfa device>`
```

`~/.aws/config`:

```ini
[default]
region=eu-west-1
cli_follow_urlparam=false

# Voltti
[profile my-federation]
region=eu-west-1
credential_process=/bin/sh -c 'unset LD_LIBRARY_PATH; aws-vault exec --duration=4h --json my-federation'
mfa_serial=<arn of mfa device>

[profile my-federated]
region=eu-west-1
source_profile=my-federation
# For aws-vault exec only, to allow using MFA without configuring mfa_serial for all profiles and breaking Terraform
include_profile=my-federation
role_arn=<fill>

# Double assume example:
[profile my-federated-app]
region=eu-west-1
source_profile=my-federated
include_profile=my-federation
role_arn=<some role assumable by my-federated>
```

## CloudFormation

### Templates

Collection of my templates: https://github.com/mikkopiu/aws-cf-templates
Great infrastructure templates: https://github.com/stelligent/cloudformation_templates
Official sample templates: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/sample-templates-services-eu-central-1.html

### Tools

- cfn_nag: https://github.com/stelligent/cfn_nag
  - Scan for insecure patterns in CloudFormation templates, easy to integrate into CI/CD pipelines:

      ```sh
      gem install cfn-nag
      cfn_nag_scan --print-suppression --input-path mytemplate.yaml
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

## S3

### Manually delete objects older than x days

Prefer S3 expirations where possible but here's a quick-and-dirty way to delete all objects recursively that are older than the specified amount of days:

```sh
BUCKET=<bucket name here>
DAYS=2
aws s3 ls --recursive s3://$BUCKET/ | while read -r line; do
	createDate=$(date -d"$(echo $line|awk {'print $1'})" +%s)
	olderThan=$(date -d"-$DAYS days" +%s)
	if [[ $createDate -lt $olderThan ]]; then
		fileName=$(echo $line|awk {'print $4'})
		if [[ $fileName != '' ]]; then
			aws s3 rm s3://$BUCKET/$fileName
		fi
	fi
done
```

Modified from source: https://shout.setfive.com/2011/12/05/deleting-files-older-than-specified-time-with-s3cmd-and-bash/

## Lambda

### Create test event for CloudWatch Logs subscription filter

Needs gzipping and base64-encoding and some wrapping JSON.

```sh
node create-test-event.js '{ "message": "Order updated" }'
```

## ECS

### Wait for deployment when using deployment circuit breakers with automatic rollbacks

```sh
npm i --save @aws-sdk/client-ecs arg
./wait-for-ecs-deploy-circuit-breaker.ts" \
  --cluster my-cluster \
  --service api-gateway-service \
  --timeout-seconds 600 \
  --version "$SERVICE_VERSION"
```
