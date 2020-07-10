#!/usr/bin/env bash

if [ "$(id -u)" == "0" ]; then
    if [ -n "$USR_ID" -a "$(id -u mgr)" != "$USR_ID" ]; then
        usermod -u $USR_ID mgr
    fi
    if [ -n "$GRP_ID" -a "$(id -g mgr)" != "$GRP_ID" ]; then
        groupmod -g $GRP_ID mgr
    fi

    chown mgr:mgr run_dbbbm.sh
    if [ -e /tmp/.ssh ]; then
        cp -r /tmp/.ssh .
        chown -R mgr:mgr .ssh
    fi

    su -c "./run_dbbbm.sh $@" mgr
    exit "$?"
fi

exec ./run_dbbbm.sh "$@"
exit "$?"
