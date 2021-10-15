#!/usr/bin/env sh

. ./dbus-wait.sh

if [ "$(df -h /var/data/ | tail -1 | awk '{print $5}' | tr -d '%')" -ge 80 ]; then
  rm -rf /var/data/*
fi

wget \
    -O "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config" \
    "${OVERRIDE_CONFIG_URL:=https://helium-assets.nebra.com/docker.config}"

# Wait for the diagnostics app is loaded
wget -q -T 10 -O - http://diagnostics:5000/initFile.txt > /dev/null
if [ $? -gt 0 ]; then
    sleep 5
    exit 1
fi

/opt/miner/gen-region.sh &

wait_for_dbus \
    && /opt/miner/bin/miner foreground
