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

variable "postgres_databases" {
  type        = list(object({ name : string, collation : optional(string), charset : optional(string) }))
  description = "The names of the Postgresql databases to deploy."
  default = [
    {
      name : "crime-portal"
    }
  ]
}
