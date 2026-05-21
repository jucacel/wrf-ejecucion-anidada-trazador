# Ejecucion WRF anidada con pulso de trazador inerte

Repositorio metodologico para documentar y reproducir un flujo WRF anidado de
tres dominios, con enfasis en una corrida corta de 4 horas sobre el dominio
fino `d03` y un pulso de trazador inerte tipo CO durante 1 hora.

El repositorio no contiene datos meteorologicos, salidas WRF, namelists privados
ni figuras generadas. Solo incluye guias, plantillas y comandos genericos.

## Proposito

Este repositorio separa el procedimiento de ejecucion WRF del repositorio de
postprocesamiento. Su funcion es dejar una ruta clara para ir desde la
preparacion WPS hasta las imagenes del penacho en `d03`, sin versionar archivos
pesados ni informacion local sensible.

El flujo documenta como:

- preparar WPS para dominios anidados `d01`, `d02`, `d03`;
- ejecutar `real.exe` para generar condiciones iniciales y de frontera;
- usar `ndown.exe` para preparar dominios anidados sucesivos si el caso usa
  anidamiento one-way;
- configurar una corrida corta de 4 horas en `d03`;
- activar un trazador inerte transportado por WRF-Chem;
- inyectar un pulso de 1 hora;
- correr `wrf.exe`;
- verificar `wrfout_d03_*`;
- generar imagenes, cortes o GIF del penacho.

## Caso conceptual

| Elemento | Valor documentado |
|---|---|
| Modelo | WRF / WRF-Chem con transporte de trazador |
| Dominios | `d01`, `d02`, `d03` |
| Dominio de interes | `d03` |
| Duracion de corrida final | 4 horas |
| Duracion del pulso | 1 hora |
| Emision | Trazador inerte tipo CO |
| Producto esperado | Mapas/cortes/GIF del penacho en `d03` |

La fecha, coordenadas, rutas, nombres de caso y namelists completos deben
definirse localmente fuera del repositorio.

## Estructura del repositorio

```text
docs/
  00_resumen_caso.md
  01_flujo_general.md
  02_wps_real_ndown.md
  03_trazador_inerte.md
  04_postproceso_imagenes.md
  05_datos_meteorologicos.md
  06_emisiones_megan_anthro_pychemiss.md
templates/
  rutas_linux.template.env
commands/
  00_download_meteo.sh
  00_download_gfs_nomads_example.sh
  00_check_entorno.sh
  01_preparar_arbol_caso.sh
  02_wps.sh
  03_real_d01_d02_d03.sh
  04_ndown_d01_d02.sh
  05_ndown_d02_d03.sh
  06_generar_pulso_trazador.sh
  07_run_wrf_d03_4h.sh
  08_postprocesar_d03.sh
  09_check_emissions_tools.sh
  10_pychemiss_local_emissions.sh
  11_prepare_emissions_links.sh
namelist_snippets/
  README.md
  namelist.input.tracer_4h.snippet
```

## Documentacion incluida

| Archivo | Contenido |
|---|---|
| `docs/00_resumen_caso.md` | Describe el caso conceptual: tres dominios, corrida corta, pulso de 1 hora y producto final. |
| `docs/01_flujo_general.md` | Resume el flujo completo WPS -> real -> ndown -> trazador -> wrf -> postproceso e incluye validaciones minimas. |
| `docs/02_wps_real_ndown.md` | Explica los pasos WPS, los productos de `real.exe` y el uso conceptual de `ndown.exe` para avanzar hacia dominios finos. |
| `docs/03_trazador_inerte.md` | Resume configuracion de trazador, ventana temporal 4 h / 1 h y criterios de verificacion en `wrfout`. |
| `docs/04_postproceso_imagenes.md` | Lista entradas, productos esperados y ejemplo de comando para generar figuras del penacho. |
| `docs/05_datos_meteorologicos.md` | Documenta opciones para descargar GFS/NOMADS, FNL/RDA o ERA5/CDS y preparar archivos para WPS. |
| `docs/06_emisiones_megan_anthro_pychemiss.md` | Explica como integrar MEGAN, ANTHRO_EMIS, PREP-CHEM-SRC, MOZBC, PyChEmiss y AAS4WRF al flujo WRF-Chem. |
| `namelist_snippets/namelist.input.tracer_4h.snippet` | Fragmento orientativo de `namelist.input` para una corrida `d03` corta con `wrfchemi_d03`. |

## Requisitos previos

Antes de usar estos comandos debe existir una instalacion funcional de:

- WPS, con `geogrid.exe`, `ungrib.exe`, `metgrid.exe` y `link_grib.csh`;
- WRF/WRF-Chem, con `real.exe`, `wrf.exe` y `ndown.exe`;
- datos geograficos WPS;
- datos meteorologicos externos compatibles con el `Vtable` elegido;
- MPI disponible para correr `real.exe`, `ndown.exe` y `wrf.exe`;
- Python para generar y validar el pulso si se usa el repositorio de
  postprocesamiento asociado;
- namelists reales del caso, mantenidos fuera de Git.

El repositorio asume una maquina Linux para la ejecucion del modelo.

## Configuracion local

Copie la plantilla y edite rutas, nombres de namelist, dominio, fuente y ventana
temporal:

```bash
cp templates/rutas_linux.template.env rutas_linux.env
vim rutas_linux.env
```

Variables principales:

| Variable | Uso |
|---|---|
| `CASE_ROOT` | Raiz del caso de corrida. |
| `WPS_DIR` | Instalacion WPS. |
| `WRF_EM_REAL` | Carpeta `test/em_real` o equivalente con ejecutables WRF. |
| `GEOG_DATA` | Datos geograficos WPS. |
| `MET_DATA_ROOT` | Datos meteorologicos externos. |
| `EMISSIONS_ROOT` | Raiz local para inventarios, salidas y archivos de emisiones. |
| `MET_DATA_SOURCE` | Fuente de datos meteorologicos: `manual`, `gfs_nomads`, `fnl_rda` o `era5_cds`. |
| `GFS_DATE`, `GFS_CYCLE`, `GFS_FORECAST_HOURS` | Parametros para descarga GFS/NOMADS si se usa `gfs_nomads`. |
| `MEGAN_DIR`, `MEGAN_DATA` | Instalacion y datos base de MEGAN para emisiones biogenicas. |
| `ANTHRO_DIR`, `ANTHRO_DATA` | Instalacion y datos de ANTHRO_EMIS para emisiones antropogenicas. |
| `PREP_CHEM_DIR`, `MOZBC_DIR` | Herramientas opcionales para emisiones regionales y fronteras quimicas. |
| `PYCHEMISS_DIR`, `PYCHEMISS_YML` | Instalacion y configuracion local de PyChEmiss. |
| `AAS4WRF_DIR` | Alternativa NCL para convertir inventarios locales a `wrfchemi`. |
| `NAMELIST_WPS` | `namelist.wps` real del caso. |
| `NAMELIST_REAL` | `namelist.input` para `real.exe`. |
| `NAMELIST_NDOWN12` | `namelist.input` para `ndown` d01 -> d02. |
| `NAMELIST_NDOWN23` | `namelist.input` para `ndown` d02 -> d03. |
| `NAMELIST_D03_TRACER` | `namelist.input` final para corrida `d03` de 4 horas. |
| `RUN_D03` | Carpeta de ejecucion final del dominio 3. |
| `TRACER_NAME` | Variable esperada en `wrfout`, por ejemplo `CO_T`, `N_SLV` o equivalente. |
| `SOURCE_I`, `SOURCE_J` | Indices de fuente en la grilla usada para el pulso. |
| `PULSE_START` | Inicio del pulso. |
| `PULSE_HOURS` | Duracion del pulso, aqui 1 hora. |
| `RUN_HOURS` | Duracion de la corrida final, aqui 4 horas. |
| `WRFCHEMI_FILE`, `WRFBIOS_FILE` | Archivos externos a enlazar como `wrfchemi_d03` y `wrfbiochemi_d03`. |
| `POSTPROC_REPO` | Ruta local al repositorio de postprocesamiento/trazadores. |

## Flujo rapido

```bash
bash commands/00_download_meteo.sh rutas_linux.env
bash commands/00_check_entorno.sh rutas_linux.env
bash commands/01_preparar_arbol_caso.sh rutas_linux.env
bash commands/02_wps.sh rutas_linux.env
bash commands/03_real_d01_d02_d03.sh rutas_linux.env
bash commands/04_ndown_d01_d02.sh rutas_linux.env
bash commands/05_ndown_d02_d03.sh rutas_linux.env
bash commands/09_check_emissions_tools.sh rutas_linux.env
bash commands/06_generar_pulso_trazador.sh rutas_linux.env
bash commands/11_prepare_emissions_links.sh rutas_linux.env
bash commands/07_run_wrf_d03_4h.sh rutas_linux.env
bash commands/08_postprocesar_d03.sh rutas_linux.env
```

Los scripts son plantillas operativas: deben revisarse contra la version local
de WRF/WPS, sistema de colas, MPI, convenciones de `ndown` y nombres reales de
archivos.

## Procedimiento detallado

### 1. Descargar o ubicar datos meteorologicos

La fuente meteorologica se define con `MET_DATA_SOURCE`.

```bash
bash commands/00_download_meteo.sh rutas_linux.env
```

Modos soportados:

- `manual`: no descarga; recuerda ubicar archivos en `MET_DATA_ROOT`.
- `gfs_nomads`: descarga GFS 0.25 grados desde NOMADS con `curl`.
- `fnl_rda`: documenta la descarga manual/autenticada desde NCAR RDA.
- `era5_cds`: documenta la descarga manual/API desde Copernicus CDS.

Para GFS/NOMADS, configurar por ejemplo:

```bash
export MET_DATA_SOURCE="gfs_nomads"
export GFS_DATE="20240901"
export GFS_CYCLE="00"
export GFS_FORECAST_HOURS="000 003 006 009 012"
```

Ese ejemplo corresponde a la ventana usada como referencia para la corrida del
pulso iniciada en `2024-09-01_00:00:00`. Descarga cinco archivos GFS 0.25
grados: `f000`, `f003`, `f006`, `f009` y `f012`.

Tambien hay un script basico autocontenido:

```bash
bash commands/00_download_gfs_nomads_example.sh "$HOME/WRF_DATA/meteo/gfs_nomads_20240901"
```

Opcionalmente se puede recortar espacialmente:

```bash
export GFS_SUBREGION="leftlon=-80&rightlon=-70&toplat=10&bottomlat=0"
```

Validar los archivos descargados:

```bash
find "$MET_DATA_ROOT" -type f | head
du -sh "$MET_DATA_ROOT"
```

Si hay `wgrib2`:

```bash
wgrib2 archivo.grib2 | head
```

Ver mas detalles en `docs/05_datos_meteorologicos.md`.

### 2. Revisar entorno

Ejecutar:

```bash
bash commands/00_check_entorno.sh rutas_linux.env
```

Debe confirmar:

- rutas principales;
- existencia de ejecutables WPS;
- existencia de `real.exe`, `wrf.exe`, `ndown.exe`;
- existencia de datos geograficos y meteorologicos;
- namelists requeridos o pendientes.

No continuar si faltan ejecutables o datos base.

### 3. Crear arbol de trabajo

```bash
bash commands/01_preparar_arbol_caso.sh rutas_linux.env
```

Crea carpetas para:

- WPS;
- `real.exe`;
- `ndown` d01 -> d02;
- `ndown` d02 -> d03;
- corrida final `d03`;
- salidas de figuras y tablas.

La carpeta `CASE_ROOT` debe quedar fuera de Git.

### 4. Ejecutar WPS

```bash
bash commands/02_wps.sh rutas_linux.env
```

Este paso enlaza WPS, usa `NAMELIST_WPS` y ejecuta:

```bash
./geogrid.exe
./ungrib.exe
./metgrid.exe
```

Validar:

```bash
ls -lh geo_em.d01.nc geo_em.d02.nc geo_em.d03.nc
ls -lh met_em.d01.* met_em.d02.* met_em.d03.* | head
```

El `namelist.wps` debe declarar tres dominios:

```fortran
max_dom = 3
parent_id = 1, 1, 2
parent_grid_ratio = 1, 3, 3
i_parent_start = 1, <i_d02>, <i_d03>
j_parent_start = 1, <j_d02>, <j_d03>
```

Si `ungrib.exe` usa datos separados de presion/superficie, ajustar `Vtable`,
`prefix` y `fg_name` segun la fuente meteorologica local.

Para GFS/NOMADS:

```bash
cd "$RUN_WPS"
ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
./link_grib.csh "$MET_DATA_ROOT"/gfs_nomads/*.grib2
./ungrib.exe
```

Para FNL/RDA o ERA5/CDS, usar el `Vtable` y estructura de archivos compatibles
con la version local de WPS.

### 5. Ejecutar `real.exe`

```bash
bash commands/03_real_d01_d02_d03.sh rutas_linux.env
```

Productos esperados:

- `wrfinput_d01`
- `wrfinput_d02`
- `wrfinput_d03`
- `wrfbdy_d01`

Validar:

```bash
grep -R "SUCCESS COMPLETE REAL_EM INIT" rsl.error.*
ls -lh wrfinput_d01 wrfinput_d02 wrfinput_d03 wrfbdy_d01
```

Si `real.exe` falla, revisar fechas de `met_em`, dominios, niveles verticales,
fisica y consistencia de `namelist.input`.

### 6. Preparar d02 con `ndown`

```bash
bash commands/04_ndown_d01_d02.sh rutas_linux.env
```

Este paso representa el puente padre-hijo entre `d01` y `d02`. Segun la version
WRF y la estrategia one-way, puede requerir ajustar nombres de archivos
intermedios, enlaces a `wrfout_d01_*` o archivos `wrfndi`.

Validar que el dominio hijo queda preparado antes de avanzar a `d03`.

### 7. Preparar d03 con `ndown`

```bash
bash commands/05_ndown_d02_d03.sh rutas_linux.env
```

Este paso repite la idea anterior, ahora de `d02` hacia `d03`.

Validar que existan los archivos necesarios para la corrida final del dominio
fino, especialmente `wrfinput_d03` y la frontera que corresponda a la
configuracion local.

### 8. Preparar pulso de trazador

Antes de generar o enlazar emisiones, revisar las herramientas disponibles:

```bash
bash commands/09_check_emissions_tools.sh rutas_linux.env
```

Si el caso requiere emisiones biogenicas, antropogenicas o inventarios locales,
ver `docs/06_emisiones_megan_anthro_pychemiss.md`. El flujo documenta:

- MEGAN para `wrfbiochemi_d0x`;
- ANTHRO_EMIS y PREP-CHEM-SRC para emisiones antropogenicas;
- PyChEmiss para inventarios locales o pulsos transformados a `wrfchemi`;
- AAS4WRF como alternativa NCL;
- MOZBC para condiciones quimicas de frontera.

Para ejecutar PyChEmiss desde una configuracion local:

```bash
bash commands/10_pychemiss_local_emissions.sh rutas_linux.env
```

Para enlazar emisiones ya generadas al directorio de corrida:

```bash
bash commands/11_prepare_emissions_links.sh rutas_linux.env
```

En el caso idealizado de este repositorio, el pulso de trazador se puede generar
directamente como `wrfchemi_d03`:

```bash
bash commands/06_generar_pulso_trazador.sh rutas_linux.env
```

El comando genera `wrfchemi_d03` usando:

- `wrfinput_d03` como referencia de grilla;
- `SOURCE_I`, `SOURCE_J` como celda fuente;
- `PULSE_START` como inicio;
- `PULSE_HOURS=1`;
- `RUN_HOURS=4`;
- `EMISSIONS_INTERVAL_MIN=60`.

Luego valida la masa o carga emitida con el script de postprocesamiento.

Antes de correr WRF, revisar:

```bash
ls -lh wrfchemi_d03
ncdump -h wrfchemi_d03 | head
```

### 9. Configurar `namelist.input` de d03

El archivo apuntado por `NAMELIST_D03_TRACER` debe estar ajustado para la
corrida corta.

Campos orientativos:

```fortran
&time_control
 run_hours              = 4,
 history_interval       = 10,
 io_form_auxinput5      = 2,
 auxinput5_inname       = 'wrfchemi_d03',
 auxinput5_interval_m   = 60,
 frames_per_auxinput5   = 5,
/

&domains
 max_dom                = 1,
/

&chem
 chem_opt               = 100,
 tracer_opt             = 1,
 num_tracer             = 1,
 io_style_emissions     = 2,
 emiss_opt              = 3,
/
```

Use `namelist_snippets/namelist.input.tracer_4h.snippet` como recordatorio, no
como namelist completo.

### 10. Ejecutar WRF en d03

```bash
bash commands/07_run_wrf_d03_4h.sh rutas_linux.env
```

Validar:

```bash
grep -R "SUCCESS COMPLETE WRF" rsl.error.*
ls -lh wrfout_d03_*
```

Verificar que WRF haya leido emisiones:

```bash
grep -R "wrfchemi" rsl.error.* | head
```

Verificar que exista trazador en salida:

```bash
ncdump -h wrfout_d03_* | grep -E "CO_T|N_SLV|S_SLV|TRACER|co"
```

### 11. Postprocesar imagenes de d03

```bash
bash commands/08_postprocesar_d03.sh rutas_linux.env
```

Productos esperados:

- cortes verticales por tiempo;
- panel tiempo-altura;
- CSV diagnostico;
- GIF opcional si el script de postprocesamiento lo genera;
- mapas o figuras adicionales si se ejecutan otros scripts.

Las salidas deben quedar bajo `OUTPUT_DIR`, fuera de Git.

## Preguntas fisicas que debe responder el postproceso

El analisis del pulso no debe limitarse a hacer figuras. Debe responder:

- donde aparece inicialmente el trazador;
- si el pulso coincide con la hora y celda fuente configuradas;
- cuanto tarda en desplazarse horizontalmente;
- hasta que altura llega durante la ventana de 4 horas;
- que fraccion queda dentro o sobre la PBLH;
- si el comportamiento es coherente con viento, topografia y mezcla vertical.

## Checklist de control de calidad

Antes de considerar exitoso el caso:

- WPS genero `geo_em` para `d01`, `d02`, `d03`.
- WPS genero `met_em` para toda la ventana temporal.
- `real.exe` termino con `SUCCESS COMPLETE REAL_EM INIT`.
- `ndown.exe` genero condiciones consistentes para los dominios hijos si aplica.
- `wrfchemi_d03` existe y corresponde a la grilla de `wrfinput_d03`.
- El pulso dura 1 hora dentro de la corrida de 4 horas.
- `wrf.exe` termino con `SUCCESS COMPLETE WRF`.
- `wrfout_d03_*` contiene la variable de trazador esperada.
- El maximo del trazador es positivo durante o despues del pulso.
- Las figuras muestran una senal fisicamente interpretable.

## Relacion con postprocesamiento

Las figuras del penacho se generan con scripts externos de postprocesamiento
WRF/trazadores. Este repo documenta el procedimiento de ejecucion; los scripts
de diagnostico pueden mantenerse en un repositorio aparte.

Repositorio asociado:

```text
https://github.com/jucacel/wrf_postprocesamiento_trazadores
```

## Datos excluidos

No versionar:

- `wrfout_*`, `wrfinput_*`, `wrfbdy_*`, `wrfchemi_*`;
- `geo_em*`, `met_em*`, GRIB/NetCDF;
- imagenes, GIF, logs completos o carpetas de corrida;
- namelists institucionales o rutas internas;
- archivos `.env` con rutas reales.

El `.gitignore` ya excluye esos patrones.

## Licencia

MIT. Ver `LICENSE`.
