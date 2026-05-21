#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-rutas_linux.env}"
source "$ENV_FILE"

mkdir -p "$RUN_D03"
cd "$RUN_D03"

ln -sf "$WRF_EM_REAL"/* .
ln -sf "$NAMELIST_D03_TRACER" namelist.input

# Ajustar origen segun salida del ndown d02 -> d03.
ln -sf "$RUN_NDOWN23"/wrfinput_d03 . 2>/dev/null || ln -sf "$RUN_REAL"/wrfinput_d03 .
ln -sf "$RUN_NDOWN23"/wrfbdy_d03 . 2>/dev/null || true

test -f wrfchemi_d03 || {
  echo "Falta wrfchemi_d03. Ejecuta commands/06_generar_pulso_trazador.sh primero."
  exit 1
}

ulimit -s unlimited
mpirun -np "${NP_WRF:-32}" ./wrf.exe

grep -R "SUCCESS COMPLETE WRF" rsl.error.* || {
  echo "wrf.exe no reporto exito."
  exit 1
}

ls -lh wrfout_d03_*
