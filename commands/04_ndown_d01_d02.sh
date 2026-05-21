#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-rutas_linux.env}"
source "$ENV_FILE"

mkdir -p "$RUN_NDOWN12"
cd "$RUN_NDOWN12"

ln -sf "$WRF_EM_REAL"/* .
ln -sf "$NAMELIST_NDOWN12" namelist.input

# Ajustar estos enlaces segun la convencion exacta de la version WRF usada.
ln -sf "$RUN_REAL"/wrfinput_d01 .
ln -sf "$RUN_REAL"/wrfinput_d02 .
ln -sf "$RUN_REAL"/wrfbdy_d01 .
ln -sf "$RUN_REAL"/wrfout_d01_* . 2>/dev/null || true

ulimit -s unlimited
mpirun -np "${NP_NDOWN:-16}" ./ndown.exe

grep -R "SUCCESS" rsl.error.* || true
ls -lh wrfinput_d02 wrfbdy_d02 2>/dev/null || true
