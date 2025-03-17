variable "location" {
  type        = string
  description = "The Azure region to deploy resources to."
  default     = "uksouth"
}

variable "pgsql_version" {
  type        = number
  description = "Version of Postgresql to deploy."
  default     = 15
}

variable "pgsql_storage_mb" {
  type        = number
  description = "Size of the PostgreSQL storage in MB."
  default     = 131072
}

variable "postgres_databases" {
  type        = list(object({ name : string, collation : optional(string), charset : optional(string) }))
  description = "The names of the Postgresql databases to deploy."
  default = [
    {
      name : "crime-portal"
    }
  ]
}
