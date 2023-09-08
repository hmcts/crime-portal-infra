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

variable "subnets" {
  type        = map(object({ address_prefixes = list(string), service_endpoints = optional(list(string), []) }))
  description = "Map of subnets to create."
}

variable "route_tables" {
  type = map(object({
    subnets = list(string),
    routes = map(object({
      address_prefix         = string,
      next_hop_type          = string,
      next_hop_in_ip_address = string
    }))
  }))
  description = "Map of route tables to create."
}

variable "network_security_groups" {
  type = map(object({
    subnet = optional(string, null)
    rules = map(object({
      priority                                   = number,
      direction                                  = string,
      access                                     = string,
      protocol                                   = string,
      source_port_range                          = optional(string, null)
      source_port_ranges                         = optional(list(string), null)
      destination_port_range                     = optional(string, null)
      destination_port_ranges                    = optional(list(string), null)
      source_address_prefix                      = optional(string, null)
      source_address_prefixes                    = optional(list(string), null)
      source_application_security_group_ids      = optional(list(string), null)
      destination_address_prefix                 = optional(string, null)
      destination_address_prefixes               = optional(list(string), null)
      destination_application_security_group_ids = optional(list(string), null)
      description                                = optional(string, null)
    }))
  }))
  description = "Map of network security groups to create."
}
