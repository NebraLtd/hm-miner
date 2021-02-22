FROM quay.io/team-helium/miner:miner-arm64_2021.02.18.0_GA
#FROM localhost:5000/miner:arm64

WORKDIR /opt/miner

COPY docker.config /opt/miner/releases/0.1.0/sys.config
COPY start-miner.sh /opt/miner/start-miner.sh
RUN chmod +x /opt/miner/start-miner.sh

ENTRYPOINT ["/opt/miner/start-miner.sh"]
