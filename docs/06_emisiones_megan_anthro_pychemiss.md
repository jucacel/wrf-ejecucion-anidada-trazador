# Preprocesamiento de emisiones: MEGAN, ANTHRO_EMIS, PyChEmiss y afines

## Objetivo

Documentar como se incorporan emisiones externas al flujo WRF-Chem anidado.
Para el caso de trazador inerte con pulso de 1 hora, el insumo minimo es
`wrfchemi_d03`. Para simulaciones quimicas completas, se suelen agregar tambien
emisiones biogenicas, antropogenicas, condiciones de frontera quimicas y, si el
caso lo requiere, fuentes naturales adicionales.

Este documento no fija rutas, fechas, inventarios ni mecanismos quimicos. Esos
detalles deben quedar en archivos locales fuera de Git.

## Que herramienta usar

| Necesidad | Herramienta tipica | Producto esperado |
|---|---|---|
| Pulso idealizado de trazador inerte | Script propio o PyChEmiss | `wrfchemi_d03` |
| Inventario local horario o gridded | PyChEmiss o AAS4WRF | `wrfchemi_d0x` o `wrfchemi_00z/12z_d0x` |
| Emisiones antropogenicas regionales/globales | ANTHRO_EMIS, PREP-CHEM-SRC u otro preprocesador | `wrfchemi_*` o archivos intermedios convertibles |
| Emisiones biogenicas | MEGAN | `wrfbiochemi_d0x` |
| Condiciones quimicas de frontera | MOZBC u otro conversor compatible | `wrfbdy_d0x` con especies quimicas |

Para una corrida corta de 4 horas con trazador inerte, no es obligatorio correr
MEGAN ni ANTHRO_EMIS si el objetivo es estudiar solamente transporte y dilucion
de un pulso idealizado. Esos pasos se vuelven necesarios cuando se requiere un
campo de fondo quimico o especies reactivas.

## Prerrequisitos comunes

Antes de ejecutar cualquier preprocesador de emisiones:

- WRF-Chem debe estar compilado con las opciones quimicas requeridas.
- `real.exe` debe haber generado `wrfinput_d0x` para los dominios objetivo.
- El mecanismo quimico de WRF-Chem debe coincidir con la especiacion del
  inventario.
- Las unidades deben estar documentadas antes de convertir a `wrfchemi`.
- La zona horaria del inventario debe transformarse a UTC si WRF corre en UTC.
- Los intervalos de emision deben coincidir con `auxinput5_interval_m`.
- Los archivos grandes, inventarios originales y salidas NetCDF deben quedar
  fuera del repositorio.

Validaciones basicas:

```bash
ncdump -h wrfinput_d03 | head
ncdump -h wrfchemi_d03 | head
ncdump -h wrfbiochemi_d03 | head
```

## Flujo recomendado dentro del caso

El orden operativo es:

1. Ejecutar WPS.
2. Ejecutar `real.exe`.
3. Preparar emisiones antropogenicas, biogenicas o locales usando `wrfinput`.
4. Preparar condiciones de frontera quimicas si el caso usa quimica regional.
5. Enlazar `wrfchemi_*` y `wrfbiochemi_*` al directorio de corrida.
6. Ejecutar `wrf.exe`.
7. Verificar en `rsl.error.*` que WRF-Chem leyo los archivos auxiliares.

En el repositorio, el punto de entrada para revisar herramientas es:

```bash
bash commands/09_check_emissions_tools.sh rutas_linux.env
```

Si se usa un inventario local con PyChEmiss:

```bash
bash commands/10_pychemiss_local_emissions.sh rutas_linux.env
bash commands/11_prepare_emissions_links.sh rutas_linux.env
```

## MEGAN: emisiones biogenicas

MEGAN genera emisiones biogenicas compatibles con la grilla WRF-Chem. El nombre
de salida depende de la version y del flujo local, pero usualmente se usa como
`wrfbiochemi_d0x`.

Procedimiento general:

1. Generar `wrfinput_d01`, `wrfinput_d02`, `wrfinput_d03` con `real.exe`.
2. Ubicar datos base de MEGAN bajo una ruta local, por ejemplo `MEGAN_DATA`.
3. Configurar el preprocesador de MEGAN para el dominio y fechas del caso.
4. Ejecutar el programa de MEGAN correspondiente a la version instalada.
5. Revisar que el archivo de salida use las dimensiones del dominio WRF.
6. Copiar o enlazar `wrfbiochemi_d0x` al directorio donde correra `wrf.exe`.
7. Activar la opcion biogenica correspondiente en `namelist.input`.

Controles recomendados:

```bash
ncdump -h "$WRFBIOS_FILE" | head
ncdump -h "$WRFBIOS_FILE" | grep -E "Time|south_north|west_east"
```

Puntos de atencion:

- MEGAN no reemplaza las emisiones antropogenicas; las complementa.
- La version de MEGAN debe ser consistente con la version de WRF-Chem.
- Si se ejecuta solamente un trazador inerte idealizado, MEGAN puede omitirse.
- Si la simulacion incluye quimica reactiva, revisar `bio_emiss_opt` y las
  opciones auxiliares exactas de la version WRF-Chem usada.

## ANTHRO_EMIS: emisiones antropogenicas

ANTHRO_EMIS se usa para transformar inventarios antropogenicos a archivos que
WRF-Chem puede leer. El flujo exacto depende del inventario, mecanismo quimico,
resolucion temporal y version de WRF-Chem.

Procedimiento general:

1. Preparar `wrfinput_d0x` del dominio objetivo.
2. Ubicar el inventario antropogenico y tablas de especiacion en `ANTHRO_DATA`.
3. Configurar el archivo de control local del preprocesador.
4. Declarar mecanismo quimico, dominios, fechas, resolucion y especies.
5. Ejecutar ANTHRO_EMIS en una carpeta de trabajo fuera de Git.
6. Convertir o renombrar salidas segun el estilo esperado por WRF-Chem.
7. Validar dimensiones, tiempos, especies y unidades.
8. Enlazar los productos como `wrfchemi_d0x` o como archivos 00z/12z si el
   flujo usa ese estilo.

Validaciones:

```bash
ncdump -h wrfchemi_d03 | grep -E "Time|emissions_zdim|south_north|west_east"
ncdump -h wrfchemi_d03 | grep -E "E_|CO|NO|SO2|PM"
```

Puntos de atencion:

- No mezclar inventarios con unidades distintas sin normalizacion explicita.
- Revisar si las emisiones estan en masa por celda, flujo por area o molar.
- Documentar el reparto temporal: horario local, UTC, perfil semanal o perfil
  mensual.
- Verificar si el archivo representa emisiones instantaneas o acumuladas.

## PREP-CHEM-SRC y otros preprocesadores globales

PREP-CHEM-SRC y herramientas equivalentes pueden preparar emisiones globales o
regionales para WRF-Chem. Son utiles cuando el caso requiere una base quimica
regional, fuentes amplias o combinacion de inventarios.

Procedimiento general:

1. Definir inventarios, fecha, resolucion y mecanismo objetivo.
2. Configurar el archivo de control del preprocesador.
3. Ejecutar en un directorio de trabajo externo al repositorio.
4. Revisar si la salida ya esta en formato `wrfchemi` o si requiere conversion.
5. Reconciliar nombres de especies con `chem_opt`.
6. Enlazar el resultado al directorio de corrida.

Usar estos preprocesadores solo cuando el objetivo fisico del caso lo justifique.
Para un pulso inerte aislado, agregan complejidad sin aportar al diagnostico
principal de transporte.

## PyChEmiss: inventarios locales y pulsos idealizados

PyChEmiss es una ruta practica para convertir emisiones locales a `wrfchemi`
usando `wrfinput` como grilla de referencia. Tambien sirve como base para un
pulso idealizado cuando el inventario se expresa como una serie temporal corta.

Entradas minimas:

- `wrfinput_d03` del dominio objetivo.
- Archivo de emisiones con tiempo, posicion o celda y magnitud.
- Configuracion YAML local, por ejemplo `pychemiss.yml`.
- Fechas de inicio y fin consistentes con la corrida WRF.

Campos tipicos del YAML:

```yaml
wrfinput_file: /ruta/local/wrfinput_d03
emission_file: /ruta/local/emisiones_horarias.csv
nx: 100
ny: 100
cell_area: 1000000.0
start_date: "2024-09-01 00:00:00"
end_date: "2024-09-01 04:00:00"
header: true
col_names: ["time", "i", "j", "co"]
sep: ","
method: nearest
```

Ejecucion generica:

```bash
cd "$PYCHEMISS_DIR"
python src/pychemiss.py "$PYCHEMISS_YML"
```

En este repositorio:

```bash
bash commands/10_pychemiss_local_emissions.sh rutas_linux.env
```

Despues de generar el archivo:

```bash
ncdump -h "$WRFCHEMI_FILE" | head
```

Opciones WRF-Chem que deben revisarse en `namelist.input`:

```fortran
auxinput5_inname     = 'wrfchemi_d<domain>'
io_style_emissions   = 2
io_form_auxinput5    = 2
auxinput5_interval_m = 60
frames_per_auxinput5 = 5
```

Si se usan archivos separados 00z/12z:

```fortran
io_style_emissions   = 1
auxinput5_inname     = 'wrfchemi_<date>_<domain>'
frames_per_auxinput5 = 12
```

## AAS4WRF como alternativa NCL

AAS4WRF puede ser util cuando el inventario local ya esta preparado como matriz
horaria y se desea generar archivos `wrfchemi` desde NCL.

Flujo conceptual:

1. Preparar `emissions.txt` o archivo equivalente con dimensiones y series
   horarias del inventario.
2. Ubicar `wrfinput_d0x` como referencia de grilla.
3. Configurar `namelist.emiss` con dominio, fechas, especies y estilo de salida.
4. Ejecutar el script NCL de AAS4WRF.
5. Revisar `wrfchemi_00z_d0x`, `wrfchemi_12z_d0x` o el nombre configurado.
6. Enlazar los productos al directorio de corrida.

Este flujo debe validarse especialmente en unidades y zona horaria, porque un
desfase temporal puede mover el pulso o perfil horario completo.

## MOZBC: condiciones quimicas de frontera

Si `chem_opt` usa especies reactivas y el dominio requiere condiciones de
frontera quimicas, se debe preparar `wrfbdy` con MOZBC u otra herramienta
compatible.

Procedimiento general:

1. Generar `wrfinput` y `wrfbdy` con `real.exe`.
2. Descargar o ubicar campos quimicos globales compatibles.
3. Configurar MOZBC con fechas, dominio, especies y mapeo quimico.
4. Ejecutar MOZBC sobre los archivos WRF del caso.
5. Validar que `wrfbdy` contiene especies quimicas de frontera.

Para un pulso de trazador inerte en `d03`, este paso puede omitirse si el
experimento no depende de quimica regional ni de concentraciones de fondo.

## Enlace al directorio de corrida

Los archivos que WRF leera deben estar en el directorio de ejecucion o enlazados
desde alli:

```bash
cd "$RUN_D03"
ln -sf /ruta/local/wrfchemi_d03 wrfchemi_d03
ln -sf /ruta/local/wrfbiochemi_d03 wrfbiochemi_d03
```

El script `commands/11_prepare_emissions_links.sh` automatiza este paso usando
las variables `WRFCHEMI_FILE` y `WRFBIOS_FILE`.

## Checklist antes de correr WRF-Chem

- `wrfinput_d03` y `wrfchemi_d03` tienen las mismas dimensiones horizontales.
- La dimension `Time` cubre toda la corrida o el periodo esperado.
- `auxinput5_interval_m` coincide con la frecuencia del archivo.
- La especie emitida existe para el mecanismo configurado.
- Las unidades fueron revisadas y documentadas localmente.
- `rsl.error.*` confirma lectura de `wrfchemi`.
- Si se usa MEGAN, `wrfbiochemi_d03` existe y WRF-Chem lo reconoce.
- Si se usa MOZBC, `wrfbdy` contiene las especies quimicas esperadas.

## Informacion que no debe subirse a Git

No versionar:

- inventarios originales;
- archivos `wrfchemi_*`, `wrfbiochemi_*`, `wrfbdy_*` o `wrfinput_*`;
- rutas internas de servidores;
- credenciales de descarga;
- namelists completos de casos sensibles;
- registros operativos con nombres propios, ubicaciones internas o datos
  institucionales.
