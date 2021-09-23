ARG HELIUM_GA_RELEASE=2021.09.16.1

FROM quay.io/team-helium/miner:miner-arm64_"$HELIUM_GA_RELEASE"_GA

WORKDIR /opt/miner

COPY docker.config /opt/miner/releases/$HELIUM_GA_RELEASE/sys.config
COPY *.sh ./

ARG HELIUM_GA_RELEASE
ENV HELIUM_GA_RELEASE $HELIUM_GA_RELEASE

RUN echo "$HELIUM_GA_RELEASE" > /etc/lsb-release

ENTRYPOINT ["/opt/miner/start-miner.sh"]
