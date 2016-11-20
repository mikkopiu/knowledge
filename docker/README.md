# Docker

## Resources

- [Dockerfile best practices](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)
- [Devicemapper configuration](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/#/configure-docker-with-devicemapper)
  - Especially useful for production deployments
- [Docker Bench for Security](https://github.com/docker/docker-bench-security)
  - For checking Docker installations and containers against common best practices
- [Docker Garbace Collection](https://github.com/spotify/docker-gc)
- [Clean up volumes](https://github.com/chadoe/docker-cleanup-volumes)

## Orchestration

- [Kontena](https://kontena.io/)
  - Higher level take on Docker container orchestration

## Miscellaneous

### Remove unused images

```shell
docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi
```