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
boot_diag_storage_account_name = "crimeportalprod"

key_vault_name = "crime-portal-kv-prod"

vm_subnet_name = "crime-portal-prod"

//TODO:
vm_private_ip  = ["10.25.245.10", "10.25.245.11"]

//TODO:
# data disks
vm_data_disks = [
  {
    datadisk1 = {
      name                     = "crimeportalvm1prod-datadisk-01"
      location                 = "uksouth"
      resource_group_name      = "crime-portal-rg-prod"
      storage_account_type     = "StandardSSD_LRS"
      disk_create_option       = "Restore"
      disk_size_gb             = "128"
      disk_tier                = null
      disk_zone                = "1"
      source_resource_id       = "" //TODO
      storage_account_id       = null
      hyper_v_generation       = null
      os_type                  = null
      disk_lun                 = "10"
      attachment_create_option = "Attach"
      disk_caching             = "ReadWrite"
    }
  },
  {
    datadisk1 = {
      name                     = "crimeportalvm2prod-datadisk-01"
      location                 = "uksouth"
      resource_group_name      = "crime-portal-rg-prod"
      storage_account_type     = "StandardSSD_LRS"
      disk_create_option       = "Restore"
      disk_size_gb             = "128"
      disk_tier                = null
      disk_zone                = "2"
      source_resource_id       = "" //TODO
      storage_account_id       = null
      hyper_v_generation       = null
      os_type                  = null
      disk_lun                 = "10"
      attachment_create_option = "Attach"
      disk_caching             = "ReadWrite"
    }
  }
]

# Dynatrace 

tenant_id = "yrk32651"
hostgroup = "PROD_CRIME_PORTAL"
server    = "https://10.10.70.8:9999/e/yrk32651/api"

cnp_vault_rg  = "core-infra-prod"
cnp_vault_sub = "8999dec3-0104-4a27-94ee-6588559729d1"

# VM Bootstrap module
nessus_install  = true
nessus_server   = "nessus-scanners-prod000005.platform.hmcts.net"
nessus_groups   = "crime-portal-prod"
nessus_key_name = "nessus-agent-key-prod"

run_command    = true
rc_script_file = "scripts/windows_cis.ps1"

# Azure Recovery Services
azurerm_recovery_services_vault_name = "crime-portal-rsv-prod"
azurerm_backup_policy_vm_name        = "crime-portal-app-daily-prod"

# Instant restore retention must be between 1 and 30 days
instant_restore_retention_days = "1"

# Backup retention daily must be between 7 and 9999
backup_retention_daily_count = "14"

# Monthly count between 1 and 60
backup_retention_monthly_count = "1"

action_group_name = "martha-prod-action-group"
short_name        = "marthaprod"
