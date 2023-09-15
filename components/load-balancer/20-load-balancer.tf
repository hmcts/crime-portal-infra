resource "azurerm_lb" "lb" {
  name                = "${var.load_balancer.name}-${var.env}"
  resource_group_name = local.resource_group_name
  location            = var.location

  sku = var.load_balancer.sku

  dynamic "frontend_ip_configuration" {
    for_each = var.load_balancer.frontend_ip_configurations
    content {
      name                          = frontend_ip_configuration.key
      subnet_id                     = data.azurerm_subnet.frontend_subnets[frontend_ip_configuration.key].id
      private_ip_address            = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
      zones                         = frontend_ip_configuration.value.zones
    }
  }

  tags = module.ctags.common_tags
}

resource "azurerm_lb_backend_address_pool" "backend" {
  for_each        = var.load_balancer.backend_address_pools
  loadbalancer_id = azurerm_lb.lb.id
  name            = each.key
}

resource "azurerm_lb_backend_address_pool_address" "backend_ip_address" {
  for_each                = { for value in local.flattened_backend_vm_ip_addresses : "${value.pool_key}-${value.ip_key}" => value }
  name                    = each.value.ip_key
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend[each.value.pool_key].id
  ip_address              = each.value.ip
  virtual_network_id      = data.azurerm_virtual_network.vnet.id
}

resource "azurerm_lb_backend_address_pool_address" "backend_vm_ip_address" {
  for_each                = { for value in local.flattened_backend_vm_ip_addresses : value.key => value }
  name                    = each.value.vm_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend[each.value.pool_key].id
  ip_address              = data.azurerm_virtual_machine.backend_vm[each.key].private_ip_address
  virtual_network_id      = data.azurerm_virtual_network.vnet.id
}

resource "azurerm_lb_probe" "probe" {
  for_each            = var.load_balancer.probes
  loadbalancer_id     = azurerm_lb.lb.id
  name                = each.key
  protocol            = each.value.protocol
  port                = each.value.port
  interval_in_seconds = each.value.interval
  probe_threshold     = each.value.threshold
  number_of_probes    = each.value.unhealthy_threshold
  request_path        = each.value.request_path
}

resource "azurerm_lb_rule" "rule" {
  for_each                       = var.load_balancer.rules
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = each.key
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  enable_floating_ip             = each.value.enable_floating_ip
  backend_address_pool_ids       = [for pool_name in each.value.backend_address_pool_names : azurerm_lb_backend_address_pool.backend[pool_name].id]
  probe_id                       = azurerm_lb_probe.probe[each.value.probe_name].id
  load_distribution              = each.value.load_distribution
}
