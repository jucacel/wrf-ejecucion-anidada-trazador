#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-rutas_linux.env}"
source "$ENV_FILE"

cd "$RUN_D03"

python "$POSTPROC_REPO/scripts/trazadores/wrf_trazadores_08_generate_wrfchemi_pulse.py" \
  --wrfinput wrfinput_d03 \
  --out-dir . \
  --domain d03 \
  --start "$PULSE_START" \
  --run-hours "$RUN_HOURS" \
  --interval-min "$EMISSIONS_INTERVAL_MIN" \
  --pulse-start "$PULSE_START" \
  --pulse-hours "$PULSE_HOURS" \
  --mass-ton "${PULSE_MASS_TON:-1}" \
  --source-ij "$SOURCE_I" "$SOURCE_J" \
  --patch-radius "${PATCH_RADIUS:-1}" \
  --emissions-zdim "${EMISSIONS_ZDIM:-1}" \
  --output-style single

python "$POSTPROC_REPO/scripts/trazadores/wrf_trazadores_09_validate_wrfchemi_mass.py" \
  --interval-min "$EMISSIONS_INTERVAL_MIN" \
  wrfchemi_d03
