ARG LSST_VER
FROM lsstsqre/centos:$LSST_VER
LABEL name="DBB handoff buffer manager" \
    vendor="LSST" \
    license="GPLv3"

USER root

# Install buffer manager and its dependencies.
ARG MNGR_VER
WORKDIR /opt/lsst/addons
RUN source /opt/lsst/software/stack/loadLSST.bash \
    && conda install --yes jsonschema \
    && git clone https://github.com/lsst-dm/dbb_buffmngrs_handoff.git \
    && cd dbb_buffmngrs_handoff \
    && git checkout $MNGR_VER \
    && setup -r . \
    && scons

# Create a non-privileged user account.
ARG GRP_ID
ARG USR_ID
RUN groupadd -g $GRP_ID mgr \
    && useradd -g $GRP_ID -m -s /bin/bash -u $USR_ID mgr

WORKDIR /home/mgr
COPY run_dbbbm.sh .
RUN chown mgr:mgr run_dbbbm.sh \
    && chmod a+x run_dbbbm.sh

USER mgr
ENTRYPOINT ["./run_dbbbm.sh"]
CMD ["-h"]
