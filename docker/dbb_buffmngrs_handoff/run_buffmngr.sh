#!/bin/bash
#
# run_buffmngr.sh: sets up and start the buffer manager

source /opt/lsst/software/stack/loadLSST.bash
setup -r /opt/lsst/addons/dbb_buffmngrs_handoff
transd.py -c $1
