subnets = {
  appgw = {
    address_prefixes  = ["10.25.246.0/28"]
    service_endpoints = ["Microsoft.Storage"]
  }
  frontend = {
    address_prefixes  = ["10.25.246.16/28"]
    service_endpoints = ["Microsoft.Storage"]
  }
  backend = {
    address_prefixes  = ["10.25.246.32/28"]
    service_endpoints = ["Microsoft.Storage"]
  }
  backend-postgresql = {
    address_prefixes  = ["10.25.246.48/28"]
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
        next_hop_in_ip_address = "10.11.72.36"
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
        destination_address_prefix = "10.25.246.0/28"
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
        source_address_prefix      = "10.25.246.0/28"
        destination_address_prefix = "10.25.246.16/28"
      }
      "allow_mgmt" = {
        priority                   = 201
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = ["10.25.247.32/27", "10.25.250.0/26", "10.11.72.32/27"]
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
        source_address_prefix      = "10.25.246.16/28"
        destination_address_prefix = "10.25.246.32/28"
      }
      "allow_sql" = {
        priority                   = 201
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "10.25.246.16/28"
        destination_address_prefix = "10.25.246.48/28"
      }
      "allow_sql_mgmt" = {
        priority                   = 202
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefixes    = ["10.25.247.32/27", "10.25.250.0/26", "10.11.72.32/27"]
        destination_address_prefix = "10.24.246.48/28"
      }
    }
  }
}

ldap_vms = {
  crime-portal-ldap-vm01-stg = {
    availability_zone = 1
  }
  crime-portal-ldap-vm02-stg = {
    availability_zone = 2
  }
}

resource_group = "crime-portal-rg-stg"

vnet_resource_group            = "InternalSpoke-rg"
vnet_name                      = "vnet-nle-int-01"
location                       = "uksouth"
subnet_address_prefix          = "10.25.245.0/27"
route_table_name               = "NLE-INTERNAL-RT"
boot_diag_storage_account_name = "crimeportalsastg"

key_vault_name = "crime-portal-kv-stg"

vm_subnet_name = "crime-portal-frontend-stg"

# data disks
vm_data_disks = [
]

# Dynatrace 

tenant_id = "yrk32651"
hostgroup = "NONPROD_CRIME_PORTAL"
server    = "https://10.10.70.8:9999/e/yrk32651/api"

cnp_vault_rg  = "cnp-core-infra"
cnp_vault_sub = "1c4f0704-a29e-403d-b719-b90c34ef14c9"

# VM Bootstrap module
nessus_install  = true
nessus_server   = "nessus-scanners-nonprod000005.platform.hmcts.net"
nessus_groups   = "Nonprod-test"
nessus_key_name = "nessus-agent-key-nonprod"

run_command    = true
rc_script_file = "scripts/windows_cis.ps1"

# Azure Recovery Services
azurerm_recovery_services_vault_name = "crime-portal-rsv-stg"
azurerm_backup_policy_vm_name        = "crime-portal-daily-bp-stg"

# Instant restore retention must be between 1 and 30 days
instant_restore_retention_days = "1"

# Backup retention daily must be between 7 and 9999
backup_retention_daily_count = "14"

# Monthly count between 1 and 60
backup_retention_monthly_count = "1"

action_group_name = "crime-portal-stg-action-group"
short_name        = "crimeportalstg"
