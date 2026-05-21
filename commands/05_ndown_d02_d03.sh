#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-rutas_linux.env}"
source "$ENV_FILE"

mkdir -p "$RUN_NDOWN23"
cd "$RUN_NDOWN23"

ln -sf "$WRF_EM_REAL"/* .
ln -sf "$NAMELIST_NDOWN23" namelist.input

# Ajustar enlaces segun salidas reales del paso d01 -> d02.
ln -sf "$RUN_NDOWN12"/wrfinput_d02 .
ln -sf "$RUN_REAL"/wrfinput_d03 .
ln -sf "$RUN_NDOWN12"/wrfbdy_d02 . 2>/dev/null || true
ln -sf "$RUN_NDOWN12"/wrfout_d02_* . 2>/dev/null || true

ulimit -s unlimited
mpirun -np "${NP_NDOWN:-16}" ./ndown.exe

grep -R "SUCCESS" rsl.error.* || true
ls -lh wrfinput_d03 wrfbdy_d03 2>/dev/null || true
