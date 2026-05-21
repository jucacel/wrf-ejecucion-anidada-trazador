#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-rutas_linux.env}"
source "$ENV_FILE"

mkdir -p "$RUN_REAL"
cd "$RUN_REAL"

ln -sf "$WRF_EM_REAL"/* .
ln -sf "$NAMELIST_REAL" namelist.input
ln -sf "$RUN_WPS"/met_em.d0* .

ulimit -s unlimited
mpirun -np "${NP_REAL:-16}" ./real.exe

grep -R "SUCCESS COMPLETE REAL_EM INIT" rsl.error.* || {
  echo "real.exe no reporto exito."
  exit 1
}

ls -lh wrfinput_d01 wrfinput_d02 wrfinput_d03 wrfbdy_d01
