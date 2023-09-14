resource "azurerm_application_gateway" "appgw" {
  for_each            = var.app_gateways
  name                = "${each.key}-${var.env}"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = module.ctags.common_tags
  zones               = each.value.availability_zones == null ? var.env == "prod" ? ["1", "2"] : [] : each.value.availability_zones

  sku {
    name     = each.value.sku_name
    tier     = each.value.sku_tier
    capacity = each.value.capacity
  }

  dynamic "autoscale_configuration" {
    for_each = each.value.sku_name == "Standard_v2" || each.value.sku_name == "WAF_v2" ? [each.value] : []
    content {
      min_capacity = each.value.min_capacity
      max_capacity = each.value.max_capacity
    }
  }

  dynamic "gateway_ip_configuration" {
    for_each = each.value.gateway_ip_configurations
    content {
      name      = gateway_ip_configuration.key
      subnet_id = data.azurerm_subnet.gateway_subnets["${each.key}-${gateway_ip_configuration.key}"].id
    }
  }

  dynamic "frontend_port" {
    for_each = each.value.frontend_ports
    content {
      name = frontend_port.key
      port = frontend_port.value.port
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configurations
    content {
      name                          = frontend_ip_configuration.key
      subnet_id                     = data.azurerm_subnet.frontend_subnets["${each.key}-${frontend_ip_configuration.key}"].id
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
      private_ip_address            = frontend_ip_configuration.value.private_ip_address
      public_ip_address_id          = frontend_ip_configuration.value.public_ip_address_id
    }
  }

  dynamic "backend_address_pool" {
    for_each = each.value.backend_address_pools
    content {
      name         = backend_address_pool.key
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses != null ? backend_address_pool.value.ip_addresses : [for vm in data.azurerm_virtual_machine.backend_vms : vm.private_ip_address]
    }
  }

  dynamic "probe" {
    for_each = each.value.probes
    content {
      name                                      = probe.key
      interval                                  = probe.value.interval
      host                                      = probe.value.host
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
      path                                      = probe.value.path
      protocol                                  = probe.value.protocol
      port                                      = probe.value.port
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
    }
  }

  dynamic "backend_http_settings" {
    for_each = each.value.backend_http_settings
    content {
      name                                = backend_http_settings.key
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      affinity_cookie_name                = backend_http_settings.value.affinity_cookie_name
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      probe_name                          = backend_http_settings.value.probe_name
      host_name                           = backend_http_settings.value.host_name
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
    }
  }

  dynamic "http_listener" {
    for_each = each.value.http_listeners
    content {
      name                           = http_listener.key
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      host_name                      = http_listener.value.host_name
    }
  }

  dynamic "request_routing_rule" {
    for_each = each.value.request_routing_rules
    content {
      name                       = request_routing_rule.key
      rule_type                  = request_routing_rule.value.rule_type
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
      priority                   = request_routing_rule.value.priority
      rewrite_rule_set_name      = each.value.sku_name == "Standard_v2" || each.value.sku_name == "WAF_v2" ? local.x_fwded_proto_ruleset : null
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = each.value.sku_name == "Standard_v2" || each.value.sku_name == "WAF_v2" ? [each.value] : []
    content {
      name = local.x_fwded_proto_ruleset

      rewrite_rule {
        name          = local.x_fwded_proto_ruleset
        rule_sequence = 100

        request_header_configuration {
          header_name  = "X-Forwarded-Proto"
          header_value = "https"
        }

        request_header_configuration {
          header_name  = "X-Forwarded-Port"
          header_value = "443"
        }

        request_header_configuration {
          header_name  = "X-Forwarded-For"
          header_value = "{var_add_x_forwarded_for_proxy}"
        }
      }
    }
  }
}
