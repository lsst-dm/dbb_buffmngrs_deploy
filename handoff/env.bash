# Version of the LSST stack to use.
export LSST_VER="d_latest"

# Version of the DBB buffer manager to use.
export MNGR_VER="1.0.0-rc1"

# Label which will be applied to the resultant Docker image. 
export TAG="${MNGR_VER}"

# User which will run the image. User MUST exists!
export USER="arc"

# Derived and internal environmental variables used by docker.
#
# WARNING
# -------
# Do NOT change unless you know what you're doing! Seriously.
export USR_ID=`id -u ${USER}`
export GRP_ID=`id -g ${USER}`
export SRC_HOME=`eval "echo ~${USER}"`
export TGT_HOME="/home/mgr"
