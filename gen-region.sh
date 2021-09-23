#!/usr/bin/env sh

# Wait until miner knows the regulatory region.
while ! /opt/miner/bin/miner info region > /dev/null 2>&1; do
    sleep 1
done

REGIONDATA=$(/opt/miner/bin/miner info region)
echo "$REGIONDATA" > /var/pktfwd/region
