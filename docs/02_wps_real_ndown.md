# WPS, real.exe y ndown.exe

## WPS para tres dominios

El `namelist.wps` debe declarar los tres dominios, relaciones de anidamiento y
datos geograficos. Los campos clave son:

```fortran
max_dom = 3
parent_id = 1, 1, 2
parent_grid_ratio = 1, 3, 3
i_parent_start = 1, <i_d02>, <i_d03>
j_parent_start = 1, <j_d02>, <j_d03>
geog_data_path = '/ruta/a/WPS_GEOG'
```

El orden normal es:

```bash
./geogrid.exe
./ungrib.exe
./metgrid.exe
```

## real.exe

`real.exe` toma `met_em*` y produce:

- `wrfinput_d01`
- `wrfinput_d02`
- `wrfinput_d03`
- `wrfbdy_d01`

En corridas one-way con `ndown`, estos archivos sirven como punto de partida
para preparar dominios hijos con mayor resolucion.

## ndown.exe

`ndown.exe` se usa para derivar condiciones del dominio padre al dominio hijo.
El patron conceptual es:

1. Correr dominio padre.
2. Preparar `wrfndi_d0x` o archivo equivalente requerido por la version WRF.
3. Configurar `namelist.input` para `max_dom = 2` en el par padre-hijo.
4. Ejecutar `ndown.exe`.
5. Usar los archivos generados para la corrida del dominio hijo.

Para llegar a `d03`:

```text
d01 -> d02
d02 -> d03
```

La implementacion exacta depende de la version WRF, configuracion de nesting y
convenciones locales de nombres.
