#!/bin/bash
#
# run_buffmngr.sh: sets up and start the buffer manager

exec &> /var/log/buffmngrs/at-handoff.log

source /opt/lsst/software/stack/loadLSST.bash
setup --verbose --root /opt/lsst/addons/dbb_buffmngrs_handoff

echo "--- Environemnt ---"
eups list --setup
echo

echo "--- Configuration ---"
cat $1
echo

echo "--- Runtime ---"
transd.py -c $1
echo

exit 0
