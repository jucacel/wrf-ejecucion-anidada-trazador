#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-rutas_linux.env}"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "No existe $ENV_FILE. Copia templates/rutas_linux.template.env como rutas_linux.env y editalo."
  exit 1
fi

source "$ENV_FILE"

mkdir -p "$MET_DATA_ROOT"

case "${MET_DATA_SOURCE:-manual}" in
  gfs_nomads)
    OUTDIR="$MET_DATA_ROOT/gfs_nomads"
    mkdir -p "$OUTDIR"

    : "${GFS_DATE:?Definir GFS_DATE=YYYYMMDD en rutas_linux.env}"
    : "${GFS_CYCLE:?Definir GFS_CYCLE=00/06/12/18 en rutas_linux.env}"
    : "${GFS_FORECAST_HOURS:?Definir GFS_FORECAST_HOURS, por ejemplo '000 003 006 009 012'}"

    BASE_URL="${GFS_NOMADS_BASE_URL:-https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl}"
    LEVELS="${GFS_LEVELS:-lev_10_m_above_ground=on&lev_2_m_above_ground=on&lev_surface=on&lev_mean_sea_level=on&lev_1000_mb=on&lev_925_mb=on&lev_850_mb=on&lev_700_mb=on&lev_500_mb=on&lev_300_mb=on&lev_200_mb=on}"
    VARS="${GFS_VARIABLES:-var_UGRD=on&var_VGRD=on&var_TMP=on&var_RH=on&var_HGT=on&var_PRES=on&var_PSFC=on&var_PRMSL=on&var_SPFH=on&var_SOILW=on&var_TSOIL=on&var_LAND=on}"
    SUBREGION="${GFS_SUBREGION:-}"

    for FH in $GFS_FORECAST_HOURS; do
      FILE="gfs.t${GFS_CYCLE}z.pgrb2.0p25.f${FH}"
      URL="${BASE_URL}?dir=%2Fgfs.${GFS_DATE}%2F${GFS_CYCLE}%2Fatmos&file=${FILE}&${LEVELS}&${VARS}"
      if [[ -n "$SUBREGION" ]]; then
        URL="${URL}&subregion=&${SUBREGION}"
      fi
      echo "Descargando $FILE"
      curl -fL --retry 3 --retry-delay 5 -o "$OUTDIR/${FILE}.grib2" "$URL"
    done

    echo "Descarga GFS terminada en $OUTDIR"
    ls -lh "$OUTDIR" | tail
    ;;

  manual|fnl_rda|era5_cds)
    cat <<EOF
MET_DATA_SOURCE=${MET_DATA_SOURCE:-manual}

Descarga manual/documentada.

- FNL/RDA: descargar desde https://rda.ucar.edu/datasets/ds083.3/
- ERA5/CDS: descargar desde https://cds.climate.copernicus.eu/
- Guardar los archivos bajo:
  $MET_DATA_ROOT

No guardar credenciales, tokens ni .cdsapirc dentro del repositorio.
EOF
    ;;

  *)
    echo "MET_DATA_SOURCE no soportado: ${MET_DATA_SOURCE}"
    echo "Valores soportados: manual, gfs_nomads, fnl_rda, era5_cds"
    exit 1
    ;;
esac
