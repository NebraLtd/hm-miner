ARG HELIUM_GA_RELEASE=2021.12.09.0
ARG BUILD_ARCH=arm64

FROM quay.io/team-helium/miner:miner-"$BUILD_ARCH"_"$HELIUM_GA_RELEASE"_GA

WORKDIR /opt/miner

ARG HELIUM_GA_RELEASE
ENV HELIUM_GA_RELEASE $HELIUM_GA_RELEASE

COPY docker.config /opt/miner/releases/"$HELIUM_GA_RELEASE"/sys.config
COPY docker.config.rockpi /opt/miner/docker.config.rockpi
COPY docker.config.5g /opt/miner/docker.config.5g
COPY *.sh /opt/miner/

RUN echo "$HELIUM_GA_RELEASE" > /etc/lsb_release

ENTRYPOINT ["/opt/miner/start-miner.sh"]
