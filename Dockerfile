ARG HELIUM_GA_RELEASE=2023.02.07.0
ARG BUILD_ARCH=arm64
ARG BLOCKCHAIN_ROCKSDB_GC_BYTES=8589934592

FROM quay.io/team-helium/miner:miner-"$BUILD_ARCH"_"$HELIUM_GA_RELEASE"_GA

WORKDIR /opt/miner

ARG HELIUM_GA_RELEASE
ENV HELIUM_GA_RELEASE $HELIUM_GA_RELEASE

ARG BLOCKCHAIN_ROCKSDB_GC_BYTES
ENV BLOCKCHAIN_ROCKSDB_GC_BYTES $BLOCKCHAIN_ROCKSDB_GC_BYTES

ENV PYTHON_DEPENDENCIES_DIR=/opt/python-dependencies

COPY requirements.txt .
COPY config_update/ .
COPY setup.py .

# hadolint ignore=DL3018
RUN apk add --no-cache --update \
        python3 \
        py3-pip && \
    pip3 install --no-cache-dir --target="$PYTHON_DEPENDENCIES_DIR" .

COPY docker.config /opt/miner/releases/"$HELIUM_GA_RELEASE"/sys.config
COPY docker.config.* /opt/miner/
COPY *.sh /opt/miner/

# Add python dependencies to PYTHONPATH
ENV PYTHONPATH="${PYTHON_DEPENDENCIES_DIR}:${PYTHONPATH}"
ENV PATH="${PYTHON_DEPENDENCIES_DIR}/bin:${PATH}"

RUN echo "$HELIUM_GA_RELEASE" > /etc/lsb_release

ENTRYPOINT ["/opt/miner/start-miner.sh"]
