#!/bin/bash
export LANG=en_US.utf8
source ${EWOC_S2_VENV}/bin/activate
exec "$@"
#run_s2c $@
