variable "env" {
  type        = string
  description = "The environment to deploy resources to."
}

variable "builtFrom" {
  type        = string
  description = "The name of the repository these resources are builtFrom."
}

variable "product" {
  type        = string
  description = "The name of the prodcut this infrastructure supports."
}

variable "ldap_vms" {
  type        = map(any)
  description = "The LDAP VMs to create role assignments for."
}

variable "frontend_vms" {
  type        = map(any)
  description = "The Frontend VMs to create role assignments for."
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID to create role assignments in."
}

