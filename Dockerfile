ARG HELIUM_GA_RELEASE=2021.10.29.0

FROM quay.io/team-helium/miner:miner-arm64_"$HELIUM_GA_RELEASE"_GA

WORKDIR /opt/miner

ARG HELIUM_GA_RELEASE
ENV HELIUM_GA_RELEASE $HELIUM_GA_RELEASE

COPY docker.config /opt/miner/releases/"$HELIUM_GA_RELEASE"/sys.config
COPY *.sh /opt/miner/

RUN echo "$HELIUM_GA_RELEASE" > /etc/lsb_release

ENTRYPOINT ["/opt/miner/start-miner.sh"]
