terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ---------------------------------------------------------------------------
# 1. Bucket S3 privado, con bloqueo de acceso público.
#    force_destroy permite que "terraform destroy" lo elimine aunque tenga
#    datos y resultados de Athena.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "datos" {
  bucket        = var.nombre_bucket
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "datos" {
  bucket = aws_s3_bucket.datos.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Los prefijos "entregas/" y "resultados-athena/" son parte de las claves de
# los objetos: se crean al subir archivos y al ejecutar consultas, por lo que
# no se declaran como directorios.

# ---------------------------------------------------------------------------
# 2. Base de datos de Glue Data Catalog.
# ---------------------------------------------------------------------------
resource "aws_glue_catalog_database" "entregas" {
  name = var.nombre_base_datos
}

# ---------------------------------------------------------------------------
# 3. Tabla externa con partition projection de fechas.
#    No se declara ninguna partición: Athena las calcula a partir de las
#    propiedades "projection.*" en cada consulta.
# ---------------------------------------------------------------------------
resource "aws_glue_catalog_table" "entregas" {
  name          = var.nombre_tabla
  database_name = aws_glue_catalog_database.entregas.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "EXTERNAL"                       = "TRUE"
    "classification"                 = "csv"
    "skip.header.line.count"         = "1"
    "projection.enabled"             = "true"
    "projection.fecha.type"          = "date"
    "projection.fecha.format"        = "yyyy-MM-dd"
    "projection.fecha.range"         = "${var.fecha_inicial},${var.fecha_final}"
    "projection.fecha.interval"      = "1"
    "projection.fecha.interval.unit" = "DAYS"
    "storage.location.template"      = "s3://${aws_s3_bucket.datos.bucket}/entregas/fecha=$${fecha}/"
  }

  # "fecha" no es una columna de los CSV: viene de la carpeta fecha=yyyy-MM-dd.
  partition_keys {
    name = "fecha"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.datos.bucket}/entregas/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim"          = ","
        "serialization.format" = ","
      }
    }

    columns {
      name = "id_envio"
      type = "string"
    }

    columns {
      name = "ciudad"
      type = "string"
    }

    columns {
      name = "transportadora"
      type = "string"
    }

    columns {
      name = "estado"
      type = "string"
    }

    columns {
      name = "duracion_minutos"
      type = "int"
    }
  }
}

# ---------------------------------------------------------------------------
# 4. Workgroup de Athena con los resultados en "resultados-athena/".
# ---------------------------------------------------------------------------
resource "aws_athena_workgroup" "entregas" {
  name          = var.nombre_workgroup
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${aws_s3_bucket.datos.bucket}/resultados-athena/"
    }
  }
}
