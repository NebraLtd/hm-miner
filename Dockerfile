ARG HELIUM_GA_RELEASE=2025.08.18.5

FROM quay.io/team-helium/miner:miner-arm64_"$HELIUM_GA_RELEASE"_GA

WORKDIR /opt/miner

ARG HELIUM_GA_RELEASE
ENV HELIUM_GA_RELEASE $HELIUM_GA_RELEASE

COPY docker.config /opt/miner/releases/"$HELIUM_GA_RELEASE"/sys.config
COPY start-miner.sh /opt/miner/start-miner.sh
COPY gen-region.sh /opt/miner/gen-region.sh

RUN echo "$HELIUM_GA_RELEASE" > /etc/lsb-release

ENTRYPOINT ["/opt/miner/start-miner.sh"]
