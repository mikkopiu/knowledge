# Docker

## Guides

- [Automatic reverse proxy for containers](https://github.com/mikkopiu/knowledge/tree/master/docker/auto-proxy)

## Resources

- [Dockerfile best practices](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)
- [Devicemapper configuration](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/#/configure-docker-with-devicemapper)
  - Especially useful for production deployments
- [Docker Bench for Security](https://github.com/docker/docker-bench-security)
  - For checking Docker installations and containers against common best practices
- [Docker Garbace Collection](https://github.com/spotify/docker-gc)
- [Clean up volumes](https://github.com/chadoe/docker-cleanup-volumes)
- [Docker networking basics](https://docs.docker.com/engine/tutorials/networkingcontainers/)
- [Docker Swarm tutorial](https://docs.docker.com/engine/swarm/swarm-tutorial/)

## Orchestration

- [Kontena](https://kontena.io/)
  - Higher level take on Docker container orchestration

## Installation

### On Ubuntu

Initially, follow the official guide: https://docs.docker.com/engine/installation/linux/ubuntulinux/

From the optional steps in the official guide, you should at least do "Manage Docker as a non-root user" to simplify your life (no need to always `sudo` when using Docker). Of course, there is a security point to be made for not doing this.

Next, audit your Docker installation with [Docker Bench for Security](https://github.com/docker/docker-bench-security):
```shell
git clone https://github.com/docker/docker-bench-security.git
# Switch to root/su, if necessary
sh docker-bench-security.sh
```

See some tips for improvement below.

#### Common installation improvements

- Set a logging level:

    ```shell
    # Open the Docker engine configuration file
    sudo vi /etc/default/docker
    # Append this to DOCKER_OPTS, and uncomment it if commented out
    --log-level=info
    # Set level to whatever you would like it to be
    ```

- Switch to some other storage driver than AUFS
  - Check this guide out:https://docs.docker.com/engine/userguide/storagedriver/selectadriver/
  - Google for more up-to-date info
- Disable legacy registries (you really should not be using them, Docker Hub and most non-official registries offer v2 by default):

    ```shell
    # Add this to DOCKER_OPTS in /etc/default/docker:
    --disable-legacy-registry
    ```
- ding

## Miscellaneous

### Remove unused images

```shell
docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi
```
