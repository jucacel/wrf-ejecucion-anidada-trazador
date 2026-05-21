#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-rutas_linux.env}"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "No existe $ENV_FILE. Copia templates/rutas_linux.template.env como rutas_linux.env y editalo."
  exit 1
fi

source "$ENV_FILE"

check_path() {
  local label="$1"
  local path="$2"
  if [[ -e "$path" ]]; then
    printf 'OK        %-18s %s\n' "$label" "$path"
  else
    printf 'PENDIENTE %-18s %s\n' "$label" "$path"
  fi
}

echo "== Directorios de emisiones =="
check_path "EMISSIONS_ROOT" "${EMISSIONS_ROOT:-}"
check_path "MEGAN_DIR" "${MEGAN_DIR:-}"
check_path "MEGAN_DATA" "${MEGAN_DATA:-}"
check_path "ANTHRO_DIR" "${ANTHRO_DIR:-}"
check_path "ANTHRO_DATA" "${ANTHRO_DATA:-}"
check_path "PREP_CHEM_DIR" "${PREP_CHEM_DIR:-}"
check_path "MOZBC_DIR" "${MOZBC_DIR:-}"
check_path "MOZART_DATA" "${MOZART_DATA:-}"
check_path "PYCHEMISS_DIR" "${PYCHEMISS_DIR:-}"
check_path "AAS4WRF_DIR" "${AAS4WRF_DIR:-}"

echo
echo "== Insumos locales =="
check_path "wrfinput_d03" "$RUN_D03/wrfinput_d03"
check_path "local emissions" "${LOCAL_EMISSIONS_FILE:-}"
check_path "pychemiss yml" "${PYCHEMISS_YML:-}"
check_path "wrfchemi" "${WRFCHEMI_FILE:-$RUN_D03/wrfchemi_d03}"
check_path "wrfbiochemi" "${WRFBIOS_FILE:-}"

echo
echo "== Comandos utiles =="
command -v ncdump >/dev/null 2>&1 && echo "OK        ncdump" || echo "PENDIENTE ncdump"
command -v ncks >/dev/null 2>&1 && echo "OK        ncks" || echo "PENDIENTE ncks"
command -v ncl >/dev/null 2>&1 && echo "OK        ncl" || echo "PENDIENTE ncl"
command -v python >/dev/null 2>&1 && echo "OK        python" || echo "PENDIENTE python"

if [[ -n "${PYCHEMISS_DIR:-}" ]]; then
  check_path "pychemiss.py" "$PYCHEMISS_DIR/src/pychemiss.py"
fi
