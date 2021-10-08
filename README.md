# hm-miner

Helium Miner Container

## Creating a release

* Create a new branch
* Edit the first line of `Dockerfile` to point to the new GA release
* Push and create a new PR

## Pre built containers

This repo automatically builds docker containers and uploads them to two repositories for easy access:
- [hm-miner on DockerHub](https://hub.docker.com/r/nebraltd/hm-miner)
- [hm-miner on GitHub Packages](https://github.com/NebraLtd/hm-miner/pkgs/container/hm-miner)

The images are tagged using the docker long and short commit SHAs for that release. The current version deployed to miners can be found in the [helium-miner-software repo](https://github.com/NebraLtd/helium-miner-software/blob/production/docker-compose.yml).
