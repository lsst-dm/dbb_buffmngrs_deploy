#!/bin/bash

# start_oods.sh: starts OODS service

script=`basename $0`

# Process commnad line options.
while getopts ":hl:" opt; do
    case ${opt} in
        l)
            lfn=${OPTARG}
            ;;
        h)
            echo "Usage: ${script} [-h] [-l logfile] config"
            exit 1
            ;;
        \?)
            echo "${script}: option '${OPTARG}' not supported."
            echo "Try '${script} -h' for more information."
            exit 1
            ;;
        :)
            echo "${script}: option '${OPTARG}' requires an argument."
            echo "Try '${script} -h' for more information."
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

# Make sure configuration file was provided.
config="$1"
if [ -z ${config} ]; then
    echo "$script: configuration file missing."
    exit 1
fi

# Redirect ouput to a file.
log=${lfn:-"/var/log/oods.log"}
if ! touch $log; then
    echo "$script: cannot create logfile '${log}'"
    exit 1
fi
exec &> ${log}

# Start OODS.
echo "--- Environment ---"
eups list --setup
echo

echo "--- Configuration ---"
cat ${config}
echo

echo "--- Runtime ---"
oods.py --loglevel INFO ${config}

exit 0
