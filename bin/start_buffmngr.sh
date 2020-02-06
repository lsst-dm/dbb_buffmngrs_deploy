#!/bin/bash
#
# start_buffmngr.sh: starts buffer manager

path=`realpath $(dirname $0)`
root=`dirname ${path}`

. ${root}/etc/env.conf

home=`eval "echo ~${USER}"`
docker container run \
    --rm \
    --user "$(id -u ${USER}):$(id -g ${USER})" \
    --volume /data/staging:/data \
    --volume /var/log/buffmngrs:/var/log/buffmngrs \
    --volume ${home}/.ssh:/home/buffmngr/.ssh:ro \
    lsstdm/buffmngr:${IMAGE_TAG}
exit 0
