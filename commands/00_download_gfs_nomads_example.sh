#!/usr/bin/env bash
set -euo pipefail

# Ejemplo autocontenido para la ventana meteorologica usada como referencia:
# inicio WRF 2024-09-01_00:00:00, corrida corta de 4 h y margen hasta f012.

OUTDIR="${1:-$PWD/gfs_nomads_20240901}"
mkdir -p "$OUTDIR"

GFS_DATE="20240901"
GFS_CYCLE="00"
GFS_FORECAST_HOURS="000 003 006 009 012"
BASE_URL="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl"

LEVELS="lev_10_m_above_ground=on&lev_2_m_above_ground=on&lev_surface=on&lev_mean_sea_level=on&lev_1000_mb=on&lev_925_mb=on&lev_850_mb=on&lev_700_mb=on&lev_500_mb=on&lev_300_mb=on&lev_200_mb=on"
VARS="var_UGRD=on&var_VGRD=on&var_TMP=on&var_RH=on&var_HGT=on&var_PRES=on&var_PSFC=on&var_PRMSL=on&var_SPFH=on&var_SOILW=on&var_TSOIL=on&var_LAND=on"

# Para descargar solo una region, descomentar y ajustar:
# SUBREGION="subregion=&leftlon=-80&rightlon=-70&toplat=10&bottomlat=0"
SUBREGION=""

for FH in $GFS_FORECAST_HOURS; do
  FILE="gfs.t${GFS_CYCLE}z.pgrb2.0p25.f${FH}"
  URL="${BASE_URL}?dir=%2Fgfs.${GFS_DATE}%2F${GFS_CYCLE}%2Fatmos&file=${FILE}&${LEVELS}&${VARS}"
  if [[ -n "$SUBREGION" ]]; then
    URL="${URL}&${SUBREGION}"
  fi

  echo "Descargando $FILE"
  echo "$URL"
  curl -fL --retry 3 --retry-delay 5 -o "$OUTDIR/${FILE}.grib2" "$URL"
done

echo "Archivos descargados en $OUTDIR"
ls -lh "$OUTDIR"
