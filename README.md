# hm-miner: Helium Miner Container

This is the codebase for the Helium miner container used on the Nebra hotspot miners.

We take the base image created by Helium from their [Quay repo](
https://quay.io/repository/team-helium/miner?tab=tags) (built from the [GitHub source](https://github.com/helium/miner)) and make some customisations to optimise it for use on our hardware including adding a start script and a script to automatically determine the regulatory region (EU868, US915 etc) from the asserted locaiton of the miner.

## Miner config file update

In the `start-miner.sh` script in this repo, you will see that we [update the included sys.config file](https://github.com/NebraLtd/hm-miner/blob/master/start-miner.sh#L9-L11) every time the miner container is loaded, using the below code:

```shell
wget \
    -O "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config" \
    "${OVERRIDE_CONFIG_URL:=https://helium-assets.nebra.com/docker.config}"
```

Our [Helium block tracker](https://github.com/NebraLtd/hm-block-tracker) automatically creates miner snapshots every ~240 blocks and at the same time also updates a `docker.config` file located [on our server](https://helium-assets.nebra.com/docker.config) with the block height and hash of the snapshot, enabling it to be ingested into the miner.

This enables our miners to sync extremely fast (called "instant sync" by some manufacturers) by downloading very up to date snapshots... ~240 blocks is considered synced to all intents and purposes and usually is [close enough to being synced](https://github.com/helium/miner/issues/957#issuecomment-899903729) that it will already be able to submit transactions to the current consensus group. Note that this is worst case scenario - as the snapshot is updated every 4 hours - so it will often be more up to date than ~240 blocks (unless you are right at the end of a 4 hour period).

## Creating a release with updated miner GA

* Create a new branch
* Edit the first line of `Dockerfile` to point to the new GA release
* Push and create a new PR

## Mr Bump

[Mr Bump](https://github.com/mr-bump) is a GitHub bot we created to automate some tasks related to the miner software. This includes updating the miner to the latest GA (and tagging / releasing this update) as well as updating the necessary `docker-compose.yml` files.

Mr Bump is currently used in the following repos:
- [hm-miner](https://github.com/NebraLtd/hm-miner)
- [hm-gatewayrs](https://github.com/NebraLtd/hm-gatewayrs)
- [helium-miner-software](https://github.com/NebraLtd/helium-miner-software)
- [light-hotspot-software](https://github.com/NebraLtd/light-hotspot-software)
- [helium-5g-software](https://github.com/NebraLtd/helium-5g-software)

## Pre built containers

This repo automatically builds docker containers and uploads them to two repositories for easy access:
- [hm-miner on DockerHub](https://hub.docker.com/r/nebraltd/hm-miner)
- [hm-miner on GitHub Packages](https://github.com/NebraLtd/hm-miner/pkgs/container/hm-miner)

The images are tagged using the docker long and short commit SHAs for that release. The current version deployed to miners can be found in the [helium-miner-software repo](https://github.com/NebraLtd/helium-miner-software/blob/production/docker-compose.yml).
