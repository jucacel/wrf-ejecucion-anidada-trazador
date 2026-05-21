# Resumen del caso

El caso documentado corresponde a una corrida WRF anidada de tres dominios con
un experimento corto de trazador inerte en el dominio fino.

## Configuracion conceptual

| Elemento | Descripcion |
|---|---|
| Modelo | WRF / WRF-Chem con transporte de trazador inerte |
| Anidamiento | Tres dominios: `d01`, `d02`, `d03` |
| Dominio objetivo | `d03` |
| Duracion analizada | 4 horas |
| Emision | Pulso de trazador inerte tipo CO |
| Duracion del pulso | 1 hora |
| Producto final | Imagenes/mapas y cortes del penacho en `d03` |

## Principio del flujo

1. Generar campos WPS para los tres dominios.
2. Ejecutar `real.exe` para el caso meteorologico base.
3. Usar `ndown.exe` para propagar condiciones hacia dominios mas finos cuando
   el flujo requiere one-way nesting.
4. Activar trazador inerte en el `namelist.input` del dominio objetivo.
5. Generar `wrfchemi` o archivo equivalente de emision para un pulso de 1 hora.
6. Ejecutar `wrf.exe` para la ventana corta de 4 horas.
7. Postprocesar `wrfout_d03_*` para generar imagenes del penacho.

## Criterio de sanitizacion

Este repositorio usa nombres genericos de caso, rutas placeholder y fechas de
ejemplo. Los datos originales, namelists completos, rutas internas y resultados
generados deben mantenerse fuera de Git.
