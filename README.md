# Ejecucion WRF anidada con pulso de trazador inerte

Repositorio metodologico para documentar y reproducir un flujo WRF anidado de
tres dominios, con enfasis en una corrida corta de 4 horas sobre el dominio
fino `d03` y un pulso de trazador inerte tipo CO durante 1 hora.

El repositorio no contiene datos meteorologicos, salidas WRF, namelists privados
ni figuras generadas. Solo incluye guias, plantillas y comandos genericos.

## Objetivo

Documentar el procedimiento para:

- preparar WPS para dominios anidados `d01`, `d02`, `d03`;
- ejecutar `real.exe` para generar condiciones iniciales y de frontera;
- usar `ndown.exe` para preparar dominios anidados sucesivos;
- activar un trazador inerte transportado por WRF-Chem;
- inyectar un pulso de 1 hora en la ventana de simulacion de 4 horas;
- correr el dominio 3 y postprocesar las imagenes del penacho.

## Estructura

```text
docs/
  00_resumen_caso.md
  01_flujo_general.md
  02_wps_real_ndown.md
  03_trazador_inerte.md
  04_postproceso_imagenes.md
templates/
  rutas_linux.template.env
commands/
  00_check_entorno.sh
  01_preparar_arbol_caso.sh
  02_wps.sh
  03_real_d01_d02_d03.sh
  04_ndown_d01_d02.sh
  05_ndown_d02_d03.sh
  06_generar_pulso_trazador.sh
  07_run_wrf_d03_4h.sh
  08_postprocesar_d03.sh
namelist_snippets/
  README.md
  namelist.input.tracer_4h.snippet
```

## Uso rapido

```bash
cp templates/rutas_linux.template.env rutas_linux.env
vim rutas_linux.env

bash commands/00_check_entorno.sh rutas_linux.env
bash commands/01_preparar_arbol_caso.sh rutas_linux.env
bash commands/02_wps.sh rutas_linux.env
bash commands/03_real_d01_d02_d03.sh rutas_linux.env
bash commands/04_ndown_d01_d02.sh rutas_linux.env
bash commands/05_ndown_d02_d03.sh rutas_linux.env
bash commands/06_generar_pulso_trazador.sh rutas_linux.env
bash commands/07_run_wrf_d03_4h.sh rutas_linux.env
bash commands/08_postprocesar_d03.sh rutas_linux.env
```

Los scripts son plantillas operativas: deben revisarse contra la instalacion
WRF/WPS local, version del modelo, sistema de colas y nombres reales de
namelist antes de ejecutarse.

## Relacion con postprocesamiento

Las figuras del penacho se generan con scripts externos de postprocesamiento
WRF/trazadores. Este repo documenta el procedimiento de ejecucion; los scripts
de diagnostico pueden mantenerse en un repositorio aparte.

## Datos excluidos

No versionar:

- `wrfout_*`, `wrfinput_*`, `wrfbdy_*`, `wrfchemi_*`;
- `geo_em*`, `met_em*`, GRIB/NetCDF;
- imagenes, GIF, logs completos o carpetas de corrida;
- namelists institucionales o rutas internas.
