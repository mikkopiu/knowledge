# Automatic container proxy

Use [nginx-proxy](https://github.com/jwilder/nginx-proxy) to create a container
that automatically creates reverse proxies for subdomains when a container
defines a `VIRTUAL_HOST` in their environment.

## Notes

**TODO:** Add Let's Encrypt support via [docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion).

When using `docker-compose v2` YAMLs, remember to create & set a Docker network to attach to.
Otherwise a new network is created based on the `docker-compose.yml` and you might not know what network to
attach your new containers into.

## Self-signing proxy

1. Copy this directory to your machine
2. Update `docker-compose.self-signing.yml` with your details
3. If not using a FQDN, update your `/etc/hosts` to contain all your subdomains
4. `docker-compose -f docker-compose.self-signing.yml up -d`

## Example

Create new Docker network:
```shell
docker network create nginx-proxy
```

Create `docker-compose.yml`:
```
version: '2'
services:
  nginx-proxy:
    image: jwilder/nginx-proxy
    container_name: nginx-proxy
    ports:
      - "80:80"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro

  whoami:
    image: jwilder/whoami
    container_name: whoami
    environment:
      - VIRTUAL_HOST=whoami.local

  dong:
    image: jwilder/whoami
    container_name: test
    environment:
      - VIRTUAL_HOST=test.local

networks:
  default:
    external:
      name: nginx-proxy

```

Boot up the containers:
```shell
docker-compose up -d
```

When using some local domain, remember to update your `/etc/hosts` file with all your subdomains:
```
...
127.0.0.1   whoami.local test.local ding.local localhost
...
```

Next, test that your can add a new container outside the `docker-compose.yml`
(**Setting the `--network=nginx-proxy` is the important part here**):
```shell
docker run -d -e "VIRTUAL_HOST=ding.local" --network=nginx-proxy --name ding jwilder/whoami
```

Now all these domains should be accessible from your browser:
- http://whoami.local
- http://test.local
- http://ding.local
