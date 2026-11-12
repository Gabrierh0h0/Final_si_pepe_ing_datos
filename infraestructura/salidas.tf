output "bucket" {
  description = "Nombre del bucket S3 del ejercicio."
  value       = aws_s3_bucket.datos.bucket
}

output "base_datos" {
  description = "Base de datos de Glue Data Catalog."
  value       = aws_glue_catalog_database.entregas.name
}

output "tabla" {
  description = "Tabla externa con partition projection."
  value       = aws_glue_catalog_table.entregas.name
}

output "workgroup" {
  description = "Workgroup de Athena para ejecutar las consultas."
  value       = aws_athena_workgroup.entregas.name
}

output "region" {
  description = "Región de despliegue."
  value       = var.region
}
