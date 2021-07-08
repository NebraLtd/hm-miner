#!/bin/sh

wget -O /opt/miner/releases/0.1.0/sys.config https://hmapi.nebra.com/docker.config

PUBLIC_KEYS=$(/opt/miner/bin/miner print_keys)
[ $? -ne 0 ] && exit 1
echo $PUBLIC_KEYS > /var/data/public_keys

/opt/miner/gen-region.sh &

/opt/miner/bin/miner foreground
