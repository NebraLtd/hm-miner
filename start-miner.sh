#!/usr/bin/env sh

if [ "$(df -h /var/data/ | tail -1 | awk '{print $5}' | tr -d '%')" -ge 80 ]; then
    rm -rf /var/data/*
fi

# Set OVERRIDE_CONFIG_URL based on BALENA_DEVICE_TYPE
cp /opt/miner/docker.config.5g "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config"
OVERRIDE_CONFIG_URL="https://helium-assets.nebra.com/docker.config"

wget \
    -O "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config" \
    "${OVERRIDE_CONFIG_URL}"

/opt/miner/gen-region.sh

/opt/miner/bin/miner foreground
