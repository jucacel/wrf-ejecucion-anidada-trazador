#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-rutas_linux.env}"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "No existe $ENV_FILE. Copia templates/rutas_linux.template.env como rutas_linux.env y editalo."
  exit 1
fi

source "$ENV_FILE"

: "${PYCHEMISS_DIR:?Debe definir PYCHEMISS_DIR en el archivo env.}"
: "${PYCHEMISS_YML:?Debe definir PYCHEMISS_YML en el archivo env.}"
: "${WRFCHEMI_FILE:=$RUN_D03/wrfchemi_d03}"

test -f "$PYCHEMISS_DIR/src/pychemiss.py" || {
  echo "No se encontro $PYCHEMISS_DIR/src/pychemiss.py"
  exit 1
}

test -f "$PYCHEMISS_YML" || {
  echo "No se encontro $PYCHEMISS_YML"
  exit 1
}

mkdir -p "$(dirname "$WRFCHEMI_FILE")"

cd "$PYCHEMISS_DIR"
python src/pychemiss.py "$PYCHEMISS_YML"

echo "PyChEmiss termino. Revise el archivo configurado como salida en $PYCHEMISS_YML."
echo "Si el archivo generado no queda en WRFCHEMI_FILE, ajustelo o enlacelo antes de correr WRF."

if [[ -f "$WRFCHEMI_FILE" ]]; then
  ls -lh "$WRFCHEMI_FILE"
  if command -v ncdump >/dev/null 2>&1; then
    ncdump -h "$WRFCHEMI_FILE" | head -40
  fi
else
  echo "PENDIENTE: no existe WRFCHEMI_FILE=$WRFCHEMI_FILE"
fi
