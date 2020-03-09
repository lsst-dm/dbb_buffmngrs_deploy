ARG STACK_VER
FROM lsstsqre/centos:$STACK_VER
LABEL name="DBB handoff buffer manager" \
    vendor="LSST" \
    license="GPLv3"

USER root

# Install buffer manager and its dependencies.
ARG MANAGER_VER
WORKDIR /opt/lsst/addons
RUN source /opt/lsst/software/stack/loadLSST.bash \
    && conda install --yes jsonschema \
    && git clone https://github.com/lsst-dm/dbb_buffmngrs_handoff.git \
    && cd dbb_buffmngrs_handoff \
    && git checkout $MANAGER_VER \
    && setup -r . \
    && scons

# Create a non-privileged user account.
ARG GID
ARG UID
RUN groupadd -g $GID buffmngr \
    && useradd -g $GID -m -s /bin/bash -u $UID buffmngr

WORKDIR /home/buffmngr
COPY run_buffmngr.sh .
COPY buffmngr.yml .
RUN chown buffmngr:buffmngr run_buffmngr.sh \
    && chmod a+x run_buffmngr.sh \
    && chown buffmngr:buffmngr buffmngr.yml \
    && chmod a+r buffmngr.yml

USER buffmngr
ENTRYPOINT ["/home/buffmngr/run_buffmngr.sh"]
CMD ["/home/buffmngr/buffmngr.yml"]
