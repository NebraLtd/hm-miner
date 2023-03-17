import os
import sentry_sdk
from urllib.parse import urlparse, parse_qs
from hm_pyhelper.hardware_definitions import get_variant_attribute
from hm_pyhelper.miner_param import parse_i2c_address, parse_i2c_bus, get_ecc_location 

def init_sentry():
    sentry_block_tracker = os.environ.get("SENTRY_MINER")
    sentry_sdk.init(
        sentry_block_tracker,
        traces_sample_rate=1.0,
    )

def populate_template(
        blessed_block,
        base_url,
        i2c_bus,
        key_slot,
        i2c_address,
        onboarding_key_slot,
        template_file='config.template'
):
    template = Template(open(template_file).read())
    block_id = blessed_block['height']
    block_hash = blessed_block['hash']

    output = template.render(
        i2c_bus=i2c_bus,
        base_url=base_url,
        key_slot=key_slot,
        blessed_block=block_id,
        i2c_address=i2c_address,
        blessed_block_hash=block_hash,
        onboarding_key_slot=onboarding_key_slot
    )
    return output


def output_config_file(config, path):
    with open(path, "w") as file:
        file.write(config)


def is_production_fleet() -> bool:
    return bool(int(os.getenv('PRODUCTION', '0')))


def is_device_type(board_name: str) -> bool:
    return bool(int(os.getenv(board_name, '0')))


def main():
    init_sentry()
    if is_production_fleet():
        base_url = 'https://helium-snapshots.nebracdn.com'
        template_path = 'config.template'
    else:
        base_url = 'https://helium-snapshots-stage.nebracdn.com'
        template_path = 'config-stage.template'

    onboarding_key_uri = False

    swarm_key_uri = get_ecc_location()
    onboarding_key_uri = get_variant_attribute('helium-fl1', 'ONBOARDING_KEY_URI')
    
    parse_result = urlparse(swarm_key_uri[0])
    i2c_bus = parse_result.hostname
    i2c_address = parse_i2c_address(parse_result.port)
    query_string = parse_qs(parse_result.query)
    key_slot = query_string["slot"][0]

    if onboarding_key_uri:
        parse_onboarding_key = urlparse(onboarding_key_uri[0])
        query_string = parse_qs(parse_onboarding_key.query)
        onboarding_key_slot = query_string["slot"][0]
    else:
        onboarding_key_slot = key_slot

    latest_snapshot = get_latest_snapshot_block(base_url)
    config = populate_template(latest_snapshot, base_url, i2c_bus, key_slot,
                               i2c_address, onboarding_key_slot, template_path)
    output_config_file(config, path)


if __name__ == '__main__':
    main()
