#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-rutas_linux.env}"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "No existe $ENV_FILE. Copia templates/rutas_linux.template.env como rutas_linux.env y editalo."
  exit 1
fi

source "$ENV_FILE"

mkdir -p "$RUN_D03"
cd "$RUN_D03"

if [[ -n "${WRFCHEMI_FILE:-}" && -f "$WRFCHEMI_FILE" ]]; then
  if [[ "$WRFCHEMI_FILE" == "$RUN_D03/wrfchemi_d03" || "$WRFCHEMI_FILE" == "wrfchemi_d03" ]]; then
    echo "wrfchemi_d03 ya esta en $RUN_D03"
  else
    ln -sf "$WRFCHEMI_FILE" wrfchemi_d03
    echo "Enlazado wrfchemi_d03 -> $WRFCHEMI_FILE"
  fi
else
  echo "PENDIENTE wrfchemi: defina WRFCHEMI_FILE o genere el pulso con commands/06_generar_pulso_trazador.sh"
fi

if [[ -n "${WRFBIOS_FILE:-}" && -f "$WRFBIOS_FILE" ]]; then
  if [[ "$WRFBIOS_FILE" == "$RUN_D03/wrfbiochemi_d03" || "$WRFBIOS_FILE" == "wrfbiochemi_d03" ]]; then
    echo "wrfbiochemi_d03 ya esta en $RUN_D03"
  else
    ln -sf "$WRFBIOS_FILE" wrfbiochemi_d03
    echo "Enlazado wrfbiochemi_d03 -> $WRFBIOS_FILE"
  fi
else
  echo "Opcional: no se enlazo wrfbiochemi_d03"
fi

ls -lh wrfchemi_d03 wrfbiochemi_d03 2>/dev/null || true
