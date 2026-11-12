# Respuestas

## 1. ¿Por qué se pudo consultar el tercer día sin registrar una partición nueva?

Porque la tabla `entregas` usa *partition projection*. En ninguna parte se registró una partición: `aws glue get-partitions` sobre la tabla devuelve 0 particiones, incluso después de cargar los tres días. Lo que guarda Glue son reglas en las propiedades de la tabla (en `infraestructura/principal.tf`): `projection.fecha.type = date`, `projection.fecha.format = yyyy-MM-dd`, `projection.fecha.range = 2026-10-01,2026-10-03`, `projection.fecha.interval = 1` (unidad `DAYS`) y `storage.location.template = s3://final-si-pepe-gabriel-giraldo/entregas/fecha=${fecha}/`.

Con esas reglas, en cada consulta Athena calcula por sí mismo las fechas posibles (1, 2 y 3 de octubre) y la carpeta de cada una a partir de la plantilla, y luego lee lo que haya allí. El 3 de octubre ya estaba dentro del rango desde el despliegue inicial; solo faltaba el archivo. Al subir `entregas/fecha=2026-10-03/entregas.csv` a la ruta que la plantilla describe, la siguiente consulta lo encontró: `verificacion_tercer_dia.sql` devolvió los 6 registros de esa fecha (`resultados/final/verificacion_tercer_dia.csv`), el total pasó de 12 a 18 registros (`resultados/final/verificacion_total_registros.csv`) y las consultas de intentos y de porcentaje de éxito coincidieron con las referencias finales. No hizo falta crawler, `MSCK REPAIR TABLE`, `ALTER TABLE ADD PARTITION` ni cambiar Terraform.

## 2. Si se subiera un archivo para el 4 de octubre manteniendo la configuración actual, ¿qué resultado se esperaría y qué se debería modificar para incluirlo?

Con la configuración actual no se vería. El rango proyectado termina en `2026-10-03`, así que Athena nunca calcula la partición `fecha=2026-10-04` ni busca en esa carpeta. El archivo quedaría guardado en S3, pero las consultas seguirían devolviendo los mismos 18 registros y no habría ningún error. Eso confirma que la proyección solo localiza las fechas que su regla describe y no descubre archivos por sí sola.

Para incluirlo, hay que ampliar el límite superior del rango en la propiedad de la tabla, es decir, cambiar `fecha_final` (que alimenta `projection.fecha.range`) a `2026-10-04` y volver a aplicar Terraform. Es un cambio de metadatos de la tabla, no una partición nueva. Además, el archivo debe seguir la misma estructura (`entregas/fecha=2026-10-04/entregas.csv`) y el mismo esquema de cinco columnas. Si no se quisiera ampliar el rango cada día, el límite superior podría definirse como `NOW` en lugar de una fecha fija.
