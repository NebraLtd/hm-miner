#!/bin/sh

wget \
    -O /opt/miner/releases/0.1.0/sys.config \
    https://helium-assets.nebra.com/docker.config

if ! PUBLIC_KEYS=$(/opt/miner/bin/miner print_keys)
then
  exit 1
else
  echo "$PUBLIC_KEYS" > /var/data/public_keys
fi

/opt/miner/gen-region.sh &

/opt/miner/bin/miner foreground
