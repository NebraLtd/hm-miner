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
elif [ "$VARIANT" = "COMP-PISCESP100" ] || [ "$VARIANT" = "piscesfl1" ]; then
  cp /opt/miner/docker.config.pisces "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config"
  OVERRIDE_CONFIG_URL="${PISCES_MINER_CONFIG_URL:-https://helium-assets.nebra.com/docker.config.pisces}"
elif [ "$VARIANT" = "COMP-PYCOM" ] || [ "$VARIANT" = "pycom-fl1" ]; then
  cp /opt/miner/docker.config.pycom "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config"
  OVERRIDE_CONFIG_URL="${PYCOM_MINER_CONFIG_URL:-https://helium-assets.nebra.com/docker.config.pycom}"
elif [ "$VARIANT" = "COMP-HELIUM" ] || [ "$VARIANT" = "helium-fl1" ]; then
  cp /opt/miner/docker.config.og "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config"
  OVERRIDE_CONFIG_URL="${HELIUM_OG_MINER_CONFIG_URL:-https://helium-assets.nebra.com/docker.config.og}"
fi

wget \
  -O "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config" \
  "${OVERRIDE_CONFIG_URL}"

if [ -z "$SWARM_KEY_URI_OVERRIDE" ]; then
  echo "SWARM_KEY_URI_OVERRIDE environment variable not defined. Using default key location."
else 
  echo "SWARM_KEY_URI_OVERRIDE environment variable found. Using value $SWARM_KEY_URI_OVERRIDE."

  bus=$(echo "$SWARM_KEY_URI_OVERRIDE" | cut -d'/' -f3 | cut -d':' -f1)
  address=$(echo "$SWARM_KEY_URI_OVERRIDE" | cut -d':' -f3 | cut -d'?' -f1)
  slot=$(echo "$SWARM_KEY_URI_OVERRIDE" | cut -d'=' -f2)
  hex_address=$(printf "%x\n" "$address")

  echo "Overriding config file with i2c bus $bus, i2c address $hex_address and key slot $slot."
  
  sed -i "s/{key_slot, [0-9]*}/{key_slot, $slot}/g" "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config"
  sed -i "s/{bus, \"i2c-[0-9]*\"}/{bus, \"$bus\"}/g" "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config"
  sed -i "s/{address, 16#[0-9]*}/{address, 16#$hex_address}/g" "/opt/miner/releases/$HELIUM_GA_RELEASE/sys.config"
fi

# Wait for the diagnostics app to be loaded
until wget -q -T 10 -O - http://diagnostics:5000/initFile.txt > /dev/null 2>&1
do
  echo "Diagnostics container not ready. Going to sleep."
  sleep 10
done

/opt/miner/gen-region.sh &

wait_for_dbus \
  && /opt/miner/bin/miner foreground
