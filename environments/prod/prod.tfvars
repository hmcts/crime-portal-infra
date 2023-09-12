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
  }
  crime-portal-ldap-vm02-prod = {
    availability_zone = 2
  }
}

resource_group = "crime-portal-rg-prod"

vnet_resource_group            = "InternalSpoke-rg"
vnet_name                      = "vnet-prod-int-01"
location                       = "uksouth"
subnet_address_prefix          = "10.25.245.0/27"
route_table_name               = "PROD-INTERNAL-RT"
boot_diag_storage_account_name = "crimeportalsaprod"

key_vault_name = "crime-portal-kv-prod"
vm_subnet_name = "crime-portal-frontend-prod"
cnp_vault_sub = "8999dec3-0104-4a27-94ee-6588559729d1"

# data disks
vm_data_disks = [
  {},
  {}
]

azurerm_recovery_services_vault_name = "crime-portal-rsv-prod"
azurerm_backup_policy_vm_name        = "crime-portal-daily-bp-prod"