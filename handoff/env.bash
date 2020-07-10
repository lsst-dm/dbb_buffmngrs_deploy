# Version of the LSST stack to use.
export LSST_VER="7-stack-lsst_distrib-w_2020_26"

# Version of the DBB buffer manager to use.
export MNGR_VER="1.1.0"

# Label which will be applied to the resultant Docker image. 
export TAG="${MNGR_VER}-${LSST_VER##*-}"

# User which will run the image. User MUST exist!
export USER="ARC"

# Derived and internal environmental variables used by docker-compose.
#
# WARNING
# -------
# Do NOT change unless you know what you're doing! Seriously.
export USR_ID=`id -u ${USER}`
export GRP_ID=`id -g ${USER}`
