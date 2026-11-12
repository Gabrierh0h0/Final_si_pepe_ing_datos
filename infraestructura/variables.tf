variable "region" {
  description = "Región de AWS donde se despliegan los recursos."
  type        = string
  default     = "us-east-1"
}

variable "nombre_bucket" {
  description = "Nombre del bucket S3 (único en todo AWS; solo minúsculas, números y guiones)."
  type        = string
  default     = "final-si-pepe-gabriel-giraldo"
}

variable "nombre_base_datos" {
  description = "Nombre de la base de datos en Glue Data Catalog (la cuenta es compartida, por eso lleva mi nombre)."
  type        = string
  default     = "final_si_pepe_gabriel_giraldo"
}

variable "nombre_tabla" {
  description = "Nombre de la tabla externa en Glue Data Catalog."
  type        = string
  default     = "entregas"
}

variable "nombre_workgroup" {
  description = "Nombre del workgroup de Athena."
  type        = string
  default     = "final_si_pepe_gabriel_giraldo"
}

variable "fecha_inicial" {
  description = "Primera fecha proyectada (incluida), formato yyyy-MM-dd."
  type        = string
  default     = "2026-10-01"
}

variable "fecha_final" {
  description = "Última fecha proyectada (incluida), formato yyyy-MM-dd."
  type        = string
  default     = "2026-10-03"
}
