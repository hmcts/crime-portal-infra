subnets = {
  appgw = {
    address_prefixes  = ["10.24.246.0/28"]
    service_endpoints = ["Microsoft.Storage"]
  }
  frontend = {
    address_prefixes  = ["10.24.246.16/28"]
    service_endpoints = ["Microsoft.Storage"]
  }
  backend = {
    address_prefixes  = ["10.24.246.32/28"]
    service_endpoints = ["Microsoft.Storage"]
  }
  backend-postgresql = {
    address_prefixes  = ["10.24.246.48/28"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    delegations = {
      flexibleserver = {
        service_name = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

route_tables = {
  rt = {
    subnets = ["appgw", "frontend", "backend", "backend-postgresql"]
    routes = {
      default = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.11.8.36"
      }
    }
  }
}

network_security_groups = {
  appgw-nsg = {
    subnets = ["appgw"]
    rules = {
      "allow_http" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "10.24.246.0/28"
      }
    }
  }
  frontend-nsg = {
    subnets = ["frontend"]
    rules = {
      "allow_http" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "10.24.246.0/28"
        destination_address_prefix = "10.24.246.16/28"
      }
      "allow_mgmt" = {
        priority                   = 201
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = ["10.24.247.32/27", "10.24.250.0/26", "10.11.8.32/27"]
        destination_address_prefix = "10.24.246.16/28"
      }
    }
  }
  backend-nsg = {
    subnets = ["backend", "backend-postgresql"]
    rules = {
      "allow_ldap" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "636"
        source_address_prefix      = "10.24.246.16/28"
        destination_address_prefix = "10.24.246.32/28"
      }
      "allow_sql" = {
        priority                   = 201
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "10.24.246.16/28"
        destination_address_prefix = "10.24.246.48/28"
      }
      "allow_sql_mgmt" = {
        priority                   = 202
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefixes    = ["10.24.247.32/27", "10.24.250.0/26", "10.11.8.32/27"]
        destination_address_prefix = "10.24.246.48/28"
      }
      "allow_sql_ss_ptl" = {
        priority                   = 203
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefixes    = ["10.147.64.0/20", "10.147.80.0/20"]
        destination_address_prefix = "10.24.246.48/28"
      }
    }
  }
}

ldap_vms = {
  crime-portal-ldap-vm01-prod = {
    availability_zone = 1
    subnet_name       = "backend"
  }
  crime-portal-ldap-vm02-prod = {
    availability_zone = 2
    subnet_name       = "backend"
  }
}

frontend_vms = {
  crime-portal-frontend-vm01-prod = {
    availability_zone = 1
    subnet_name       = "frontend"
  }
  crime-portal-frontend-vm02-prod = {
    availability_zone = 2
    subnet_name       = "frontend"
  }
}

location      = "uksouth"
cnp_vault_sub = "8999dec3-0104-4a27-94ee-6588559729d1"

ldap_users = {
  "DTS Platform Operations SC" = {
    is_group               = true
    group_security_enabled = true
    role_type              = "admin"
  }
}

frontend_users = {
  "DTS Platform Operations SC" = {
    is_group               = true
    group_security_enabled = true
    role_type              = "admin"
  }
}

subscription_id = "17390ec1-5a5e-4a20-afb3-38d8d726ae45"

app_gateways = {
  crime-portal-appgw = {
    gateway_ip_configurations = {
      crime-portal-appgw-gw-ipconfig = {
        subnet_name = "appgw"
      }
    }
    frontend_ports = {
      http = {
        port = 80
      }
    }
    frontend_ip_configurations = {
      crime-portal-appgw-fe-ipconfig = {
        subnet_name = "appgw"
      }
    }
    backend_address_pools = {
      crime-portal-appgw-pool = {
        virtual_machine_names = ["crime-portal-frontend-vm01-prod", "crime-portal-frontend-vm02-prod"]
      }
    }
    probes = {
      http = {}
    }
    backend_http_settings = {
      crime-portal-appgw-http-settings = {
        port     = 80
        protocol = "Http"
      }
    }
    http_listeners = {
      crime-portal-appgw-http-listener = {
        frontend_ip_configuration_name = "crime-portal-appgw-fe-ipconfig"
        frontend_port_name             = "Http"
        protocol                       = "Http"
      }
    }
    request_routing_rules = {
      crime-portal-appgw-http-rule = {
        http_listener_name         = "crime-portal-appgw-http-listener"
        backend_address_pool_name  = "crime-portal-appgw-pool"
        backend_http_settings_name = "crime-portal-appgw-http-settings"
        rule_type                  = "Basic"
      }
    }
  }
}
