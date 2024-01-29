This repo contains a dockerized version of the NGINX-based Freebrowser backend instance.

## Installation and usage

1. Install docker as per https://docs.docker.com/engine/install/ubuntu/. Tested on Ubuntu 22.04.
2. Build the docker image and run the container:

```bash
sudo docker build -t fbnginx_image .
sudo docker run --name fbnginx -v logs:/opt/fbnginx/logs --network host -d fbnginx_image
```

Note: `--network host` is used for production environment to maximize performance and avoid double NAT. Alternatively, `-p 443:443 -p 80:80 -p 5353:5353 -p 5353:5353/udp` can be used to expose ports to the host machine.

Stopping container: `sudo docker stop fbnginx`

Removing container: `sudo docker rm fbnginx`

3. Check the logs:

```bash
sudo docker logs fbnginx -f
sudo less +F /var/lib/docker/volumes/logs/_data/access.log
sudo less +F /var/lib/docker/volumes/logs/_data/error.log
```

## Settings

NGINX uses config files from `conf` directory. Main config file is `nginx.conf`.