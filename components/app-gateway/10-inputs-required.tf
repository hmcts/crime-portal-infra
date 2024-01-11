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

variable "app_gateway" {
  type = object({
    name               = string
    availability_zones = optional(list(string))
    sku_name           = optional(string, "Standard_v2")
    sku_tier           = optional(string, "Standard_v2")
    capacity           = optional(number)
    min_capacity       = optional(number, 1)
    max_capacity       = optional(number, 10)
    gateway_ip_configurations = map(object({
      subnet_name = string
    }))
    frontend_ports = map(object({
      port = number
    }))
    frontend_ip_configurations = optional(map(object({
      subnet_name                   = optional(string)
      private_ip_address_allocation = optional(string, "Dynamic")
      private_ip_address            = optional(string)
      public_ip_address_name        = optional(string)
    })))
    backend_address_pools = map(object({
      ip_addresses          = optional(list(string))
      fqdns                 = optional(list(string))
      virtual_machine_names = optional(list(string))
    }))
    probes = map(object({
      interval                                  = optional(number, 20)
      host                                      = optional(string)
      pick_host_name_from_backend_http_settings = optional(bool)
      path                                      = optional(string, "/")
      protocol                                  = optional(string, "Http")
      port                                      = optional(number)
      timeout                                   = optional(number, 15)
      unhealthy_threshold                       = optional(number, 3)
    }))
    backend_http_settings = map(object({
      cookie_based_affinity               = optional(string, "Disabled")
      affinity_cookie_name                = optional(string)
      port                                = number
      protocol                            = string
      request_timeout                     = optional(number)
      probe_name                          = optional(string)
      host_name                           = optional(string)
      pick_host_name_from_backend_address = optional(bool)
    }))
    http_listeners = map(object({
      frontend_ip_configuration_name = string
      frontend_port_name             = string
      protocol                       = string
      host_name                      = optional(string)
    }))
    request_routing_rules = map(object({
      rule_type                  = string
      http_listener_name         = string
      backend_address_pool_name  = optional(string)
      backend_http_settings_name = optional(string)
      priority                   = optional(number, 20)
    }))
  })
  description = "Values to use when deploy the app gateway(s)"
}
