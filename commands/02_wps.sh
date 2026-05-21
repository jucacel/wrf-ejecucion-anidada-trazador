#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-rutas_linux.env}"
source "$ENV_FILE"

mkdir -p "$RUN_WPS"
cd "$RUN_WPS"

ln -sf "$WPS_DIR"/* .
ln -sf "$NAMELIST_WPS" namelist.wps

ulimit -s unlimited

./geogrid.exe

# Ajustar Vtable y link_grib.csh segun la fuente meteorologica usada.
# Ejemplo generico:
# ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
# ./link_grib.csh "$MET_DATA_ROOT"/*
./ungrib.exe

./metgrid.exe

ls -lh geo_em.d01.nc geo_em.d02.nc geo_em.d03.nc
ls -lh met_em.d01.* met_em.d02.* met_em.d03.* | head
