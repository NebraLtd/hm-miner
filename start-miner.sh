#!/usr/bin/env sh

. ./dbus-wait.sh

if [ "$(df -h /var/data/ | tail -1 | awk '{print $5}' | tr -d '%')" -ge 80 ]; then
    rm -rf /var/data/*
fi

# Set OVERRIDE_CONFIG_URL based on BALENA_DEVICE_TYPE
OVERRIDE_CONFIG_URL="${RASPBERRYPI_MINER_CONFIG_URL:-https://helium-assets.nebra.com/docker.config}"

if [ "$BALENA_DEVICE_TYPE" = "rockpi-4b-rk3399" ]; then
  cp /opt/miner/docker.config.rockpi "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config"
  OVERRIDE_CONFIG_URL="${ROCKPI_MINER_CONFIG_URL:-https://helium-assets.nebra.com/docker.config.rockpi}"
elif [ "$BALENA_DEVICE_TYPE" = "intel-nuc" ]; then
  cp /opt/miner/docker.config.5g "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config"
  OVERRIDE_CONFIG_URL="${5G_MINER_CONFIG_URL:-https://helium-assets.nebra.com/docker.config.5g}"
fi

wget \
    -O "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config" \
    "${OVERRIDE_CONFIG_URL}"

# Wait for the diagnostics app to be loaded
until wget -q -T 10 -O - http://diagnostics:5000/initFile.txt > /dev/null 2>&1
do
    echo "Diagnostics container not ready. Going to sleep."
    sleep 10
done

/opt/miner/gen-region.sh &

wait_for_dbus \
    && /opt/miner/bin/miner foreground
