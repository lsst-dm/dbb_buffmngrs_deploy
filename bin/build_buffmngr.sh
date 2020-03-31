#!/bin/bash
#
# build_buffmngr.sh: build a Docker image for the buffer manager

script=`basename $0`
path=`realpath $(dirname $0)`
root=`dirname ${path}`

. ${root}/etc/handoff.conf

appdir="${root}/docker/dbb_buffmngrs_handoff"
if [ ! -d ${appdir} ]; then
    echo "${script}: directory ${appdir} not found."
    exit 1
fi
docker build \
   --build-arg STACK_VER \
   --build-arg MANAGER_VER \
   --build-arg UID=$(id -u ${USER}) \
   --build-arg GID=$(id -g ${USER}) \
   --tag lsstdm/at-dbbbm:${IMAGE_TAG} \
   ${appdir}	
exit 0
