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
    availability_zone     = string
    subnet_name           = string
    private_ip            = optional(string)
    size                  = optional(string, "Standard_D2ds_v5")
    install_xdr_agent     = optional(bool, false)
    install_xdr_collector = optional(bool, false)
    install_docker        = optional(bool, false)
  }))
  description = "The frontend VMs to deploy."
}

variable "ldap_vms" {
  type = map(object({
    availability_zone     = string
    subnet_name           = string
    private_ip            = optional(string)
    size                  = optional(string, "Standard_D2ds_v5")
    install_xdr_agent     = optional(bool, false)
    install_xdr_collector = optional(bool, false)
    install_docker        = optional(bool, false)
  }))
  description = "The LDAP VMs to deploy."
}

variable "cnp_vault_sub" {
  type        = string
  description = "Subscription for the CNP key vault"
}

variable "subnets" {
  type = map(object({
    address_prefixes  = list(string),
    service_endpoints = optional(list(string), []),
    use_default_rt    = optional(bool, false)
    delegations = optional(map(object({
      service_name = string,
      actions      = optional(list(string), [])
    })))
  }))
  description = "Map of subnets to refernence."
}

variable "xdr_tags" {
  description = "A map of tags specifically for XSIAM Cortex."
  type        = map(string)
}