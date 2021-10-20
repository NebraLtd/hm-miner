#!/usr/bin/env sh

. ./dbus-wait.sh

if [ "$(df -h /var/data/ | tail -1 | awk '{print $5}' | tr -d '%')" -ge 80 ]; then
    rm -rf /var/data/*
fi

wget \
    -O "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config" \
    "${OVERRIDE_CONFIG_URL:=https://helium-assets.nebra.com/docker.config}"

# Wait for the diagnostics app is loaded
until wget -q -T 10 -O - http://diagnostics:5000/initFile.txt > /dev/null 2>&1
do
    echo "Diagnostics container not ready. Going to sleep."
    sleep 10
done

if ! PUBLIC_KEYS=$(/opt/miner/bin/miner print_keys)
then
  exit 1
else
  echo "$PUBLIC_KEYS" > /var/data/public_keys
fi

/opt/miner/gen-region.sh &

wait_for_dbus \
    && /opt/miner/bin/miner foreground
