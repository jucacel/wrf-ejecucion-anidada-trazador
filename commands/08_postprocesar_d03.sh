#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-rutas_linux.env}"
source "$ENV_FILE"

OUTDIR="$OUTPUT_DIR/figures/d03_tracer_4h"
mkdir -p "$OUTDIR"

python "$POSTPROC_REPO/scripts/trazadores/wrf_trazadores_07_desplazamiento_vertical.py" \
  --run-dir "$RUN_D03" \
  --domain d03 \
  --tracer-name "$TRACER_NAME" \
  --i "$SOURCE_I" \
  --j "$SOURCE_J" \
  --axis x \
  --max-height 2500 \
  --auto-max-height \
  --height-bin 25 \
  --outdir "$OUTDIR" \
  --tag pulso_inerte_d03_4h

echo "Figuras en $OUTDIR"
