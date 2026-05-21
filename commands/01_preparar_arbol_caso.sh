#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-rutas_linux.env}"
source "$ENV_FILE"

mkdir -p \
  "$CASE_ROOT" \
  "$NAMELIST_ROOT" \
  "$RUN_WPS" \
  "$RUN_REAL" \
  "$RUN_NDOWN12" \
  "$RUN_NDOWN23" \
  "$RUN_D03" \
  "$OUTPUT_DIR"/{logs,figures,tables}

echo "Arbol creado:"
find "$CASE_ROOT" -maxdepth 3 -type d | sort
