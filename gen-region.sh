#!/usr/bin/env sh

# we want to check and update region file forever
while :
do
    # Wait until miner knows the regulatory region, we don't want to 
    # write some random strings to region file
    while ! /opt/miner/bin/miner info region > /dev/null 2>&1; do
        sleep 1
    done

    # update region file every 60 seconds
    REGIONDATA=$(/opt/miner/bin/miner info region)
    echo "$REGIONDATA" > /var/pktfwd/region
    sleep 60
done

