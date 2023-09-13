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

variable "frontend_vms" {
  type = map(object({
    availability_zone = string,
    subnet_name       = string
  }))
  description = "The frontend VMs to deploy."
}

variable "ldap_vms" {
  type = map(object({
    availability_zone = string,
    subnet_name       = string
  }))
  description = "The LDAP VMs to deploy."
}

variable "cnp_vault_sub" {
  type        = string
  description = "Subscription for the CNP key vault"
}
