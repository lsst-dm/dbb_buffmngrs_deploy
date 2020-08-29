ARG LSST_VER
FROM lsstsqre/centos:$LSST_VER AS build
USER root

# Compile and install bbcp.
RUN yum --assumeyes install gcc-c++ make openssl-devel zlib-devel

ARG BBCP_VER
RUN mkdir /builds
COPY bbcp-${BBCP_VER}.tar.gz /builds
RUN cd /builds \
    && tar xzf bbcp-${BBCP_VER}.tar.gz \
    && cd bbcp/src \
    && make

ARG LSST_VER
FROM lsstsqre/centos:$LSST_VER
LABEL name="DBB handoff buffer manager" \
    vendor="LSST" \
    license="GPLv3"
USER root

COPY --from=build /builds/bbcp/bin/amd64_linux31/bbcp /usr/bin

# Create a non-privileged user account.
RUN groupadd mgr \
    && useradd -g mgr -m -s /bin/bash mgr

# Copy the init script.
COPY docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN chmod +x /bin/docker-entrypoint.sh

# Install buffer manager and its dependencies.
ARG MNGR_VER
WORKDIR /opt/lsst/addons
RUN source /opt/lsst/software/stack/loadLSST.bash \
    && git clone https://github.com/lsst-dm/dbb_buffmngrs_handoff.git \
    && cd dbb_buffmngrs_handoff \
    && git checkout $MNGR_VER \
    && setup -r . \
    && scons

# Copy service startup script.
WORKDIR /home/mgr
COPY run_dbbbm.sh .
RUN chmod +x run_dbbbm.sh

ENTRYPOINT ["/bin/docker-entrypoint.sh"]
CMD ["-h"]

