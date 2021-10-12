#!/usr/bin/env sh

. ./dbus-wait.sh

if [ "$(df -h /var/data/ | tail -1 | awk '{print $5}' | tr -d '%')" -ge 80 ]; then
  rm -rf /var/data/*
fi

wget \
    -O "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config" \
    "${OVERRIDE_CONFIG_URL:=https://helium-assets.nebra.com/docker.config}"

ECC_SUCCESSFUL_TOUCH_FILEPATH=/var/data/gwmfr_ecc_provisioned
while ! [ -f "$ECC_SUCCESSFUL_TOUCH_FILEPATH" ];
do
    echo "Waiting for touch file at $ECC_SUCCESSFUL_TOUCH_FILEPATH."
    sleep 5
done

echo "Touch file found at $ECC_SUCCESSFUL_TOUCH_FILEPATH. Starting miner."

if ! PUBLIC_KEYS=$(/opt/miner/bin/miner print_keys)
then
  exit 1
else
  echo "$PUBLIC_KEYS" > /var/data/public_keys
fi

/opt/miner/gen-region.sh &

wait_for_dbus \
	&& /opt/miner/bin/miner foreground
