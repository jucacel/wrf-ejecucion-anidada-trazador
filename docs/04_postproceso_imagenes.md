# Postproceso de imagenes del penacho

## Entradas

- `wrfout_d03_*` de la corrida de 4 horas.
- Variable de trazador, por ejemplo `CO_T`, `N_SLV`, `S_SLV` o equivalente.
- Coordenadas o indices de la fuente.
- Carpeta de salida para PNG/GIF/CSV.

## Productos esperados

- Mapas en planta del penacho por tiempo.
- Cortes verticales por la fuente o transecto.
- Serie temporal de maximos o carga integrada.
- GIF opcional de evolucion.

## Ejemplo generico

```bash
python /ruta/a/wrf_postprocesamiento/scripts/trazadores/wrf_trazadores_07_desplazamiento_vertical.py \
  --run-dir "$RUN_D03" \
  --domain d03 \
  --tracer-name CO_T \
  --i "$SOURCE_I" \
  --j "$SOURCE_J" \
  --axis x \
  --max-height 2500 \
  --auto-max-height \
  --height-bin 25 \
  --tag pulso_inerte_d03_4h
```

## Criterios de control de calidad

- Las figuras deben mostrar una senal positiva del trazador.
- El instante inicial debe coincidir con la hora del pulso.
- No debe haber saturacion completa de escala si se desea analizar transporte.
- El centroide y maximo deben moverse de forma compatible con el campo de viento.
