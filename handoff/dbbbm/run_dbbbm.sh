#!/usr/bin/env bash
#
# run_mngr.sh: sets up and start the DBB buffer manager

script=`basename $0`

while getopts ":h" opt; do
    case ${opt} in
        h )
            echo "Usage: ${script} CONFIG"
            exit 0
            ;;
        \? )
            echo "${script}: option '${OPTARG}' not recognized."          
            echo "Try '${script} -h' for more information."                     
            exit 1                                         
            ;;
    esac
done
shift $((OPTIND-1))

config="$1"
if [ -z "${config}" ]; then
    echo "${script}: missing configuration file"
    echo "Try '${script} -h' for more information."
    exit 1
fi

if [ ! -f "${config}" ]; then
    echo "${script}: configuration file '${config}' not found"
    exit 1
fi

# Redirect output to the log file specified in the manager's configuration file.
log=`grep '^ *file:' ${config} | sed 's/^ *//' | cut -d \  -f 2 -`
if [ -n "${log}" ]; then
    exec &> ${log}
fi

# Find out location of the SQLite database in the manager's configuration file.
db=`grep '^ *engine:' ${config} | \
        sed 's/^ *//' | cut -d \  -f 2 - | \
        sed 's/^"*[^\/]*\/\/\/\(\/\{0,1\}[^"]*\)"*$/\1/'`

source /opt/lsst/software/stack/loadLSST.bash
setup --root /opt/lsst/addons/dbb_buffmngrs_handoff

echo "--- Environment ---"
eups list --setup
echo

echo "--- Configuration ---"
cat ${config}
echo

echo "--- Runtime ---"
if [ ! -e ${db} ]; then
	echo "Creating SQLite database at \"${db}\"."
	hdfmgr initdb ${config}
fi
hdfmgr run ${config}
echo

exit "$?"
