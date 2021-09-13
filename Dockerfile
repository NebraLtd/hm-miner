ARG HELIUM_GA_RELEASE=2021.09.03.0_GA

FROM quay.io/team-helium/miner:miner-arm64_$HELIUM_GA_RELEASE

RUN rm -rf /run && rm -rf /var/run

WORKDIR /opt/miner

COPY docker.config /opt/miner/releases/$HELIUM_GA_RELEASE/sys.config
COPY start-miner.sh /opt/miner/start-miner.sh
COPY gen-region.sh /opt/miner/gen-region.sh

ARG HELIUM_GA_RELEASE
ENV HELIUM_GA_RELEASE $HELIUM_GA_RELEASE

ENTRYPOINT ["/opt/miner/start-miner.sh"]
