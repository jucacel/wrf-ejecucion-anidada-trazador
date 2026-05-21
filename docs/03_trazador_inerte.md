# Trazador inerte y pulso de 1 hora

## Objetivo

Emitir un pulso de trazador inerte durante 1 hora dentro de una ventana de
simulacion de 4 horas en el dominio `d03`.

## Configuracion conceptual

El `namelist.input` debe activar el transporte del trazador y la lectura de
emisiones auxiliares si el pulso se entrega como `wrfchemi`.

Campos tipicos que deben revisarse:

```fortran
chem_opt = 100
tracer_opt = 1
num_tracer = 1
io_style_emissions = 2
auxinput5_interval_m = 60
frames_per_auxinput5 = 5
```

## Ventana temporal

Para una corrida de 4 horas con pulso de 1 hora:

```text
run_start     = T0
run_end       = T0 + 4 h
pulse_start   = T0
pulse_end     = T0 + 1 h
output_window = T0 ... T0 + 4 h
```

La salida recomendada para diagnostico es cada 10 a 60 minutos, segun el costo
computacional y el detalle deseado del penacho.

## Verificacion

Despues de `wrf.exe`, revisar:

- existencia de `wrfout_d03_*`;
- presencia de variable de trazador;
- maximo positivo durante o despues del pulso;
- ubicacion inicial coherente con la celda fuente;
- desplazamiento vertical/horizontal consistente con viento y PBLH.
