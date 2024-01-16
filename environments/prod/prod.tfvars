subnets = {
  gateway = {
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
    subnets = ["frontend", "backend", "backend-postgresql"]
    routes = {
      default = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.11.8.36"
      }
    }
  }
  rt-gateway = {
    subnets = ["gateway"]
    routes = {
      RFC_1918_A = {
        address_prefix         = "10.0.0.0/8"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.11.8.36"
      }
      RFC_1918_B = {
        address_prefix         = "172.16.0.0/12"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.11.8.36"
      }
      RFC_1918_C = {
        address_prefix         = "192.168.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.11.8.36"
      }
    }
  }
}

network_security_groups = {
  gateway-nsg = {
    subnets = ["gateway"]
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
      "allow_https" = {
        priority                   = 201
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "10.24.246.0/28"
      }
      "appgw_allow_internet_in" = {
        priority                   = 202
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
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
        source_address_prefix      = "*"
        destination_address_prefix = "10.24.246.16/28"
      }
      "allow_https" = {
        priority                   = 201
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "10.24.246.16/28"
      }
      "allow_mgmt" = {
        priority                   = 202
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = ["10.24.247.32/27", "10.24.250.0/26", "10.11.8.32/27"]
        destination_address_prefix = "10.24.246.16/28"
      }
      "allow_lb" = {
        priority                   = 203
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "10.24.246.16/28"
      }
      "allow_intra_subnet" = {
        priority                   = 204
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.24.246.16/28"
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
        destination_port_range     = "10389"
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
      "allow_mgmt" = {
        priority                     = 202
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Tcp"
        source_port_range            = "*"
        destination_port_ranges      = ["5432", "22"]
        source_address_prefixes      = ["10.24.247.32/27", "10.24.250.0/26", "10.11.8.32/27"]
        destination_address_prefixes = ["10.24.246.48/28", "10.24.246.32/28"]
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
      "allow_sql_postgres_ha" = {
        priority                   = 204
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "10.24.246.48/28"
      }
      "allow_sql_postgres_backup_storage" = {
        priority                   = 205
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "Storage"
      }
      "allow_intra_subnet" = {
        priority                   = 206
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.24.246.32/28"
        destination_address_prefix = "10.24.246.32/28"
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
  "DTS Crime Portal VM Login (env:production)" = {
    is_group               = true
    group_security_enabled = true
    role_type              = "user"
  }
  "DTS Crime Portal VM Admin Login (env:production)" = {
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
  "DTS Crime Portal VM Login (env:production)" = {
    is_group               = true
    group_security_enabled = true
    role_type              = "user"
  }
  "DTS Crime Portal VM Admin Login (env:production)" = {
    is_group               = true
    group_security_enabled = true
    role_type              = "admin"
  }
}

subscription_id = "17390ec1-5a5e-4a20-afb3-38d8d726ae45"

load_balancer = {
  name = "crime-portal-lb"
  sku  = "Standard"
  frontend_ip_configurations = {
    crime-portal-feip01-prod = {
      subnet_name = "lb"
    },
    crime-portal-feip02-prod = {
      subnet_name = "lb"
    }
  }
  backend_address_pools = {
    crime-portal-bap01-prod = {
      virtual_machine_names = ["crime-portal-frontend-vm01-prod", "crime-portal-frontend-vm02-prod"]
    },
    crime-portal-bap02-prod = {
      virtual_machine_names = ["crime-portal-frontend-vm01-prod", "crime-portal-frontend-vm02-prod"]
    },
  }
  probes = {
    crime-portal-probe01-prod = {
      protocol     = "Http"
      request_path = "/"
      port         = 80
    },
    crime-portal-probe02-prod = {
      protocol     = "Https"
      request_path = "/"
      port         = 443
    }
  }
  rules = {
    crime-portal-rule01-prod = {
      protocol                       = "Tcp"
      frontend_port                  = 80
      backend_port                   = 80
      frontend_ip_configuration_name = "crime-portal-feip01-prod"
      backend_address_pool_names     = ["crime-portal-bap01-prod"]
      probe_name                     = "crime-portal-probe01-prod"
      load_distribution              = "SourceIP"
    },
    crime-portal-rule02-prod = {
      protocol                       = "Tcp"
      frontend_port                  = 443
      backend_port                   = 443
      frontend_ip_configuration_name = "crime-portal-feip02-prod"
      backend_address_pool_names     = ["crime-portal-bap02-prod"]
      probe_name                     = "crime-portal-probe02-prod"
      load_distribution              = "SourceIP"
    },
  }
}
