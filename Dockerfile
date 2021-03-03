FROM quay.io/team-helium/miner:latest-arm64

ARG UPDATE=2021-03-03-11-28

WORKDIR /opt/miner

COPY docker.config /opt/miner/releases/0.1.0/sys.config
COPY start-miner.sh /opt/miner/start-miner.sh
COPY gen-region.sh /opt/miner/gen-region.sh

RUN chmod +x /opt/miner/start-miner.sh
RUN chmod +x /opt/miner/gen-region.sh

ENTRYPOINT ["/opt/miner/start-miner.sh"]
