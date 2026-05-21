#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-rutas_linux.env}"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "No existe $ENV_FILE. Copia templates/rutas_linux.template.env como rutas_linux.env y editalo."
  exit 1
fi

source "$ENV_FILE"

echo "== Rutas principales =="
printf 'CASE_ROOT=%s\nWPS_DIR=%s\nWRF_EM_REAL=%s\nGEOG_DATA=%s\nMET_DATA_ROOT=%s\n' \
  "$CASE_ROOT" "$WPS_DIR" "$WRF_EM_REAL" "$GEOG_DATA" "$MET_DATA_ROOT"

echo
echo "== Ejecutables WPS =="
ls -lh "$WPS_DIR/geogrid.exe" "$WPS_DIR/ungrib.exe" "$WPS_DIR/metgrid.exe"

echo
echo "== Ejecutables WRF =="
ls -lh "$WRF_EM_REAL/real.exe" "$WRF_EM_REAL/wrf.exe" "$WRF_EM_REAL/ndown.exe"

echo
echo "== Datos =="
ls -ld "$GEOG_DATA" "$MET_DATA_ROOT"

echo
echo "== Namelists esperados =="
for f in "$NAMELIST_WPS" "$NAMELIST_REAL" "$NAMELIST_NDOWN12" "$NAMELIST_NDOWN23" "$NAMELIST_D03_TRACER"; do
  [[ -f "$f" ]] && echo "OK $f" || echo "PENDIENTE $f"
done
