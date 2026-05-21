# Descarga de datos meteorologicos

WRF necesita condiciones meteorologicas externas para WPS. Este repositorio no
versiona datos GRIB/NetCDF; solo documenta como descargarlos o ubicarlos en una
carpeta de trabajo local.

## Fuentes comunes

| Fuente | Uso tipico | Acceso |
|---|---|---|
| GFS/NOMADS | Corridas recientes o casi operativas. Buena opcion para pruebas reproducibles recientes. | https://nomads.ncep.noaa.gov/ |
| FNL/NCAR RDA | Analisis global historico. Requiere cuenta y aceptar terminos en RDA. | https://rda.ucar.edu/datasets/ds083.3/ |
| ERA5/CDS | Reanalisis horario; requiere cuenta CDS y API configurada. | https://cds.climate.copernicus.eu/ |

## Criterios para escoger fuente

- Para una prueba corta reciente: GFS 0.25 grados via NOMADS suele ser la ruta
  mas simple.
- Para reconstruccion historica con analisis final: FNL/RDA es una opcion
  robusta, pero requiere autenticacion.
- Para estudios retrospectivos con consistencia climatica: ERA5/CDS es
  adecuado, pero requiere preparar archivos de presion y superficie compatibles
  con WPS.

## Ventana temporal

Descargar datos que cubran al menos:

```text
inicio_wrf - spinup_previo  ...  fin_wrf + margen
```

Para una corrida final de 4 horas puede bastar con pocas horas, pero WPS/WRF
normalmente requieren que los tiempos de `met_em` cubran exactamente la ventana
del `namelist.input`. Si se hacen pasos previos con dominios padre o `ndown`,
descargar la ventana completa que cubre esos pasos.

## Variables minimas para WPS

La lista exacta depende de la fuente y del `Vtable`, pero para WRF se requieren
campos de atmosfera y superficie. Verificar que la fuente incluya, como minimo:

- viento horizontal en niveles de presion o modelo;
- temperatura;
- humedad;
- geopotencial/altura;
- presion;
- temperatura y humedad cerca de superficie;
- presion de superficie o MSLP segun Vtable;
- variables de suelo/superficie necesarias para la configuracion fisica.

## Opcion A: GFS via NOMADS

NOMADS permite descargar subconjuntos GRIB2 usando `filter_gfs_0p25.pl`.
El script `commands/00_download_meteo.sh` implementa una plantilla generica para
GFS 0.25 grados:

```bash
bash commands/00_download_meteo.sh rutas_linux.env
```

Variables relevantes en `rutas_linux.env`:

```bash
export MET_DATA_SOURCE="gfs_nomads"
export GFS_DATE="20240901"
export GFS_CYCLE="00"
export GFS_FORECAST_HOURS="000 003 006 009 012"
export GFS_LEVELS="lev_10_m_above_ground=on&lev_2_m_above_ground=on&lev_surface=on&lev_mean_sea_level=on&lev_1000_mb=on&lev_925_mb=on&lev_850_mb=on&lev_700_mb=on&lev_500_mb=on&lev_300_mb=on&lev_200_mb=on"
export GFS_VARIABLES="var_UGRD=on&var_VGRD=on&var_TMP=on&var_RH=on&var_HGT=on&var_PRES=on&var_PSFC=on&var_PRMSL=on&var_SPFH=on&var_SOILW=on&var_TSOIL=on&var_LAND=on"
```

### Ejemplo usado para la corrida del pulso

Para la corrida documentada en este repositorio se preparo una ventana corta
iniciando el `2024-09-01_00:00:00`, con salida final de 4 horas y margen hasta
`f012` para cubrir WPS, `real.exe`, pruebas de consistencia y pasos anidados.

Configuracion usada como referencia:

```bash
export MET_DATA_SOURCE="gfs_nomads"
export GFS_DATE="20240901"
export GFS_CYCLE="00"
export GFS_FORECAST_HOURS="000 003 006 009 012"
```

Archivos esperados:

```text
gfs.t00z.pgrb2.0p25.f000.grib2
gfs.t00z.pgrb2.0p25.f003.grib2
gfs.t00z.pgrb2.0p25.f006.grib2
gfs.t00z.pgrb2.0p25.f009.grib2
gfs.t00z.pgrb2.0p25.f012.grib2
```

Ejecucion con el script principal:

```bash
cp templates/rutas_linux.template.env rutas_linux.env
vim rutas_linux.env
bash commands/00_download_meteo.sh rutas_linux.env
```

Tambien se incluye un script basico, independiente del archivo `.env`, que deja
claro el URL construido para cada hora:

```bash
bash commands/00_download_gfs_nomads_example.sh "$HOME/WRF_DATA/meteo/gfs_nomads_20240901"
```

Si esos archivos ya no estan disponibles en NOMADS por antiguedad del ciclo,
usar una fuente historica equivalente, por ejemplo FNL/RDA o un archivo
operativo/historico local, manteniendo los mismos tiempos requeridos por WPS.

Despues de descargar, configurar WPS con `Vtable.GFS` y enlazar los GRIB:

```bash
cd "$RUN_WPS"
ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
./link_grib.csh "$MET_DATA_ROOT"/gfs_nomads/*.grib2
./ungrib.exe
```

## Opcion B: FNL desde NCAR RDA

FNL historico requiere cuenta RDA. Procedimiento recomendado:

1. Crear cuenta en RDA.
2. Aceptar los terminos del dataset.
3. Descargar por la interfaz web o script generado por RDA.
4. Guardar los GRIB en una carpeta local, por ejemplo:

```text
$MET_DATA_ROOT/fnl/
```

5. En WPS, usar el Vtable correspondiente a FNL/GFS segun la version WPS.

Ejemplo conceptual:

```bash
cd "$RUN_WPS"
ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
./link_grib.csh "$MET_DATA_ROOT"/fnl/*
./ungrib.exe
```

No versionar scripts con tokens, cookies o credenciales RDA.

## Opcion C: ERA5 desde CDS

ERA5 se descarga via CDS web/API. Procedimiento recomendado:

1. Crear cuenta en Copernicus CDS.
2. Aceptar licencia del dataset.
3. Configurar la API local segun la documentacion CDS.
4. Descargar niveles de presion y variables de superficie.
5. Convertir/organizar los archivos para WPS segun la guia de la version WPS
   usada.

Ejemplo conceptual de estructura:

```text
$MET_DATA_ROOT/era5/
  pressure/
  surface/
```

No versionar `.cdsapirc`, claves API ni scripts con credenciales.

## Validacion antes de WPS

Antes de ejecutar `ungrib.exe`:

```bash
find "$MET_DATA_ROOT" -type f | head
du -sh "$MET_DATA_ROOT"
```

Si hay `wgrib2`:

```bash
wgrib2 archivo.grib2 | head
```

Luego de `ungrib.exe`, validar que existan archivos intermedios:

```bash
ls FILE:* FILE_* 2>/dev/null | head
```

Luego de `metgrid.exe`, validar:

```bash
ls -lh met_em.d01.* met_em.d02.* met_em.d03.* | head
```
