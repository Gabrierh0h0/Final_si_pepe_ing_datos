# Entregas: S3 + Glue + Athena con partition projection

Entrega del examen final de Ingeniería de datos. El enunciado original está en [ENUNCIADO.md](ENUNCIADO.md).

Los datos viven en S3, Glue Data Catalog guarda el esquema y las reglas de proyección de fechas, y Athena consulta los CSV sin registrar particiones.

## Prerrequisitos

- Terraform >= 1.5 (probado con 1.17.1).
- AWS CLI v2 (probado con 2.40.0), configurado con `aws configure` o `aws login`.
- Región: `us-east-1`.
- Permisos del usuario IAM sobre S3, Glue y Athena (los entrega el grupo del docente).
- Las credenciales nunca se guardan en el repositorio: `.gitignore` excluye credenciales, `*.tfstate*`, `.terraform/` y `*.tfvars`.

Comprobar la identidad antes de empezar:

```bash
aws sts get-caller-identity
```

## Recursos (todos en `infraestructura/`)

| Recurso | Nombre |
| --- | --- |
| Bucket S3 privado | `final-si-pepe-gabriel-giraldo` |
| Base de datos Glue | `final_si_pepe_gabriel_giraldo` |
| Tabla externa | `entregas` (partición `fecha`, projection de `2026-10-01` a `2026-10-03`) |
| Workgroup Athena | `final_si_pepe_gabriel_giraldo` (resultados en `s3://final-si-pepe-gabriel-giraldo/resultados-athena/`) |

La cuenta de AWS es compartida, por eso los nombres llevan mi nombre. El bucket no puede llevar guiones bajos.

## Despliegue

```bash
cd infraestructura
terraform init
terraform validate
terraform plan
terraform apply
terraform output -json > ../evidencias/outputs.json
```

La salida de `terraform apply` se guarda en `evidencias/aplicacion_terraform.txt`.

## Etapa inicial: días 1 y 2

1. Subir **solo** los archivos de los días 1 y 2, uno por uno (sin carga recursiva):

   ```bash
   aws s3 cp "data/entregas/fecha=2026-10-01/entregas.csv" "s3://final-si-pepe-gabriel-giraldo/entregas/fecha=2026-10-01/entregas.csv"
   aws s3 cp "data/entregas/fecha=2026-10-02/entregas.csv" "s3://final-si-pepe-gabriel-giraldo/entregas/fecha=2026-10-02/entregas.csv"
   ```

2. Comprobar que la tabla tiene **12 registros** (`SELECT COUNT(*) FROM final_si_pepe_gabriel_giraldo.entregas`, ejecución `0fa3aaf3-873c-49c4-abf8-186a376d51c6`, resultado 12).
3. Ejecutar en el workgroup `final_si_pepe_gabriel_giraldo` las tres consultas de `consultas/`: `intentos_por_fecha_estado.sql`, `porcentaje_exito_por_fecha_ciudad.sql` y `duracion_promedio_2026-10-02.sql`.
4. Guardar los resultados en `resultados/inicial/` y registrar cada ejecución en `evidencias/ejecuciones_athena.csv` (etapa `inicial`).
5. Comparar con `resultados_esperados/*_inicial.csv` y `duracion_promedio_2026-10-02.csv`: las tres salidas son idénticas.

## Etapa final: día 3

Sin modificar Terraform ni la tabla, y sin crawlers, `MSCK REPAIR TABLE` ni `ALTER TABLE ADD PARTITION`:

1. Subir el archivo del día 3:

   ```bash
   aws s3 cp "data/entregas/fecha=2026-10-03/entregas.csv" "s3://final-si-pepe-gabriel-giraldo/entregas/fecha=2026-10-03/entregas.csv"
   ```

2. Ejecutar `consultas/verificacion_tercer_dia.sql` (Athena ejecuta una sentencia por vez, así que cada bloque se corre por separado):
   - Bloque 1: los 6 registros del `2026-10-03` → `resultados/final/verificacion_tercer_dia.csv`.
   - Bloque 2: el total de la tabla, **18** registros → `resultados/final/verificacion_total_registros.csv`.
3. Repetir `intentos_por_fecha_estado.sql` y `porcentaje_exito_por_fecha_ciudad.sql` y guardar los resultados en `resultados/final/`.
4. Registrar todas las ejecuciones en `evidencias/ejecuciones_athena.csv` (etapa `final`).
5. Comparar con `resultados_esperados/*_final.csv`: ambas salidas son idénticas, y los conteos por estado del día 3 salen en el archivo de intentos.

Las consultas del `2026-10-03` solo requirieron subir el archivo: la tabla tiene 0 particiones registradas (`aws glue get-partitions`), porque las fechas las calcula la proyección. Las respuestas conceptuales están en [respuestas.md](respuestas.md).

## Limpieza

Primero se guardan y se suben las evidencias (commit y push). Después:

1. Vaciar el bucket, incluidos los datos de `entregas/` y los resultados de `resultados-athena/`:

   ```bash
   aws s3 rm s3://final-si-pepe-gabriel-giraldo/ --recursive
   ```

2. Destruir todos los recursos del ejercicio (bucket, base de datos de Glue, tabla y workgroup) y guardar la salida:

   ```bash
   cd infraestructura
   terraform destroy
   ```

   La salida se guarda en `evidencias/eliminacion_terraform.txt`.
3. Comprobar que no queda nada (`aws s3 ls`, `aws glue get-databases` y `aws athena list-work-groups` ya no muestran los recursos del ejercicio).

Nunca se suben al repositorio `terraform.tfstate`, `tfplan`, `.terraform/` ni credenciales.
