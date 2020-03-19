# Beach PHP

![](https://github.com/flownative/docker-beach-php/workflows/Build%20Docker%20Image/badge.svg)
![](https://github.com/flownative/docker-beach-php/workflows/Daily%20Releases/badge.svg)

A Docker image providing [PHP-FPM](https://www.php.net/) for Flownative
Beach and Local Beach. Compared to other PHP images, this one is
tailored to run without root privileges. All processes use an
unprivileged user and much work has been put into providing proper
console output and meaningful messages.

![Screenshot with example log output](docs/beach-php-log-example.png
"Example log output")

## tl;dr

```bash
$ docker run flownative/beach-php
```

## Example usage

tbd.

## Configuration

### Logging

By default, the PHP logs are written to STDOUT / STDERR. That way, you
can follow logs by watching container logs with `docker logs` or using a
similar mechanism in Kubernetes or your actual platform.

### Environment variables

| Variable Name                  | Type    | Default                               | Description                                                        |
|:-------------------------------|:--------|:--------------------------------------|:-------------------------------------------------------------------|
| PHP_BASE_PATH                  | string  | /opt/flownative/php                   | Base path for PHP (read-only)                                      |

## Security aspects

This image is designed to run as a non-root container. Using an
unprivileged user generally improves the security of an image, but may
have a few side-effects, especially when you try to debug something by
logging in to the container using `docker exec`.

When you are running this image with Docker or in a Kubernetes context,
you can take advantage of the non-root approach by disallowing privilege
escalation:

```yaml
$ docker run flownative/beach-php:7.4 --security-opt=no-new-privileges
```

## Building this image

Build this image with `docker build`. You need to specify the desired
version of `flownative/php`, which this image is derived from:

```bash
docker build \
    --build-arg PHP_BASE_IMAGE=flownative/php:7.4.3 \
    -t flownative/beach-php:7.4.3 .
```
