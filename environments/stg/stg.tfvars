subnets = {
  gateway = {
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
    subnets = ["frontend", "backend", "backend-postgresql"]
    routes = {
      default = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.11.72.36"
      }
    }
  }
  rt-gateway = {
    subnets = ["gateway"]
    routes = {
      RFC_1918_A = {
        address_prefix         = "10.0.0.0/8"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.11.72.36"
      }
      RFC_1918_B = {
        address_prefix         = "172.16.0.0/12"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.11.72.36"
      }
      RFC_1918_C = {
        address_prefix         = "192.168.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.11.72.36"
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
        destination_address_prefix = "10.25.246.0/28"
      }
      "allow_https" = {
        priority                   = 201
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "10.25.246.0/28"
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
        destination_address_prefix = "10.25.246.16/28"
      }
      "allow_https" = {
        priority                   = 201
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "10.25.246.16/28"
      }
      "allow_mgmt" = {
        priority                   = 202
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = ["10.25.247.32/27", "10.25.250.0/26", "10.11.72.32/27"]
        destination_address_prefix = "10.25.246.16/28"
      }
      "allow_lb" = {
        priority                   = 203
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "10.25.246.16/28"
      }
      "allow_intra_subnet" = {
        priority                   = 204
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.25.246.16/28"
        destination_address_prefix = "10.25.246.16/28"
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
      "allow_mgmt" = {
        priority                     = 202
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Tcp"
        source_port_range            = "*"
        destination_port_ranges      = ["5432", "22"]
        source_address_prefixes      = ["10.25.247.32/27", "10.25.250.0/26", "10.11.72.32/27"]
        destination_address_prefixes = ["10.25.246.48/28", "10.25.246.32/28"]
      }
      "allow_sql_ss_ptl" = {
        priority                   = 203
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefixes    = ["10.147.64.0/20", "10.147.80.0/20"]
        destination_address_prefix = "10.25.246.48/28"
      }
      "allow_sql_postgres_ha" = {
        priority                   = 204
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "10.25.246.48/28"
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
        source_address_prefix      = "10.25.246.32/28"
        destination_address_prefix = "10.25.246.32/28"
      }
    }
  }
}

ldap_vms = {
  crime-portal-ldap-vm01-stg = {
    availability_zone = 1
    subnet_name       = "backend"
  }
  crime-portal-ldap-vm02-stg = {
    availability_zone = 2
    subnet_name       = "backend"
  }
}

frontend_vms = {
  crime-portal-frontend-vm01-stg = {
    availability_zone = 1
    subnet_name       = "frontend"
  }
  crime-portal-frontend-vm02-stg = {
    availability_zone = 2
    subnet_name       = "frontend"
  }
}

location      = "uksouth"
cnp_vault_sub = "1c4f0704-a29e-403d-b719-b90c34ef14c9"

ldap_users = {
  "DTS Platform Operations" = {
    is_group               = true
    group_security_enabled = true
    role_type              = "admin"
  }
  "DTS Crime Portal VM Login (env:staging)" = {
    is_group               = true
    group_security_enabled = true
    role_type              = "user"
  }
  "DTS Crime Portal VM Admin Login (env:staging)" = {
    is_group               = true
    group_security_enabled = true
    role_type              = "admin"
  }
}

frontend_users = {
  "DTS Platform Operations" = {
    is_group               = true
    group_security_enabled = true
    role_type              = "admin"
  }
  "DTS Crime Portal VM Login (env:staging)" = {
    is_group               = true
    group_security_enabled = true
    role_type              = "user"
  }
  "DTS Crime Portal VM Admin Login (env:staging)" = {
    is_group               = true
    group_security_enabled = true
    role_type              = "admin"
  }
}

subscription_id = "ae75b9fb-7d34-4112-82ff-64bd3855ce27"

app_gateway = {
  name               = "crime-portal-appgw"
  availability_zones = ["1", "2"]
  gateway_ip_configurations = {
    crime-portal-gwip01-stg = {
      subnet_name = "gateway"
    }
  }
  frontend_ports = {
    http = {
      port = 80
    }
    test = {
      port = 81
    }
  }
  frontend_ip_configurations = {
    crime-portal-private-stg = {
      subnet_name                   = "gateway"
      private_ip_address_allocation = "Static"
      private_ip_address            = "10.25.246.4"
    }
    crime-portal-public-stg = {
      public_ip_address_name = "crime-portal-appgw-stg-pip"
    }
  }
  backend_address_pools = {
    crime-portal-bap01-stg = {
      virtual_machine_names = ["crime-portal-frontend-vm01-stg", "crime-portal-frontend-vm02-stg"]
    }
  }
  probes = {
    http = {
      host = "crimeportal.staging.apps.hmcts.net"
    }
    https = {
      host     = "lncs-crimeportal-notify-uat.lncs.hmcs"
      protocol = "Https"
      port     = 443
    }
  }
  backend_http_settings = {
    crime-portal-behttp01-stg = {
      port                  = 80
      protocol              = "Http"
      cookie_based_affinity = "Enabled"
      probe_name            = "http"
    }
    crime-portal-behttps01-stg = {
      port                           = 443
      protocol                       = "Https"
      probe_name                     = "https"
      trusted_root_certificate_names = ["crime-portal-uat"]
    }
  }
  http_listeners = {
    crime-portal-http-listener = {
      frontend_ip_configuration_name = "crime-portal-private-stg"
      frontend_port_name             = "Http"
      protocol                       = "Http"
    }
    test-listener = {
      frontend_ip_configuration_name = "crime-portal-private-stg"
      frontend_port_name             = "http"
      protocol                       = "Http"
    }
  }
  request_routing_rules = {
    crime-portal-http-rule = {
      http_listener_name         = "crime-portal-http-listener"
      backend_address_pool_name  = "crime-portal-bap01-stg"
      backend_http_settings_name = "crime-portal-behttp01-stg"
      rule_type                  = "Basic"
    }
    crime-portal-test-rule = {
      http_listener_name         = "test-listener"
      backend_address_pool_name  = "crime-portal-bap01-stg"
      backend_http_settings_name = "crime-portal-behttps01-stg"
      rule_type                  = "Basic"
    }
  }
  trusted_root_certificates = {
    crime-portal-uat = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tDQpNSUlENFRDQ0FzbWdBd0lCQWdJRVB3RTYzakFOQmdrcWhraUc5dzBCQVFzRkFEQ0JoekVMTUFrR0ExVUVCaE1DDQpSMEl4RnpBVkJnTlZCQWdURGtkeVpXRjBaWElnVEc5dVpHOXVNUTh3RFFZRFZRUUhFd1pNYjI1a2IyNHhEREFLDQpCZ05WQkFvVEEwTkhTVEVRTUE0R0ExVUVDeE1IU25WemRHbGpaVEV1TUN3R0ExVUVBeE1sYkc1amN5MWpjbWx0DQpaWEJ2Y25SaGJDMXViM1JwWm5rdGRXRjBMbXh1WTNNdWFHMWpjekFlRncweU16RXdNVE14TXpReU16TmFGdzB5DQpOREF4TVRFeE16UXlNek5hTUlHSE1Rc3dDUVlEVlFRR0V3SkhRakVYTUJVR0ExVUVDQk1PUjNKbFlYUmxjaUJNDQpiMjVrYjI0eER6QU5CZ05WQkFjVEJreHZibVJ2YmpFTU1Bb0dBMVVFQ2hNRFEwZEpNUkF3RGdZRFZRUUxFd2RLDQpkWE4wYVdObE1TNHdMQVlEVlFRREV5VnNibU56TFdOeWFXMWxjRzl5ZEdGc0xXNXZkR2xtZVMxMVlYUXViRzVqDQpjeTVvYldOek1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBenN2elpnekJIYWY2DQpsWjgzSG1vR1pVdGQvN3JGMmQzS0w3M3hRM0JZeW5FLzBTT1JlZy9CUmh6bEMwaG9XV2RvVHgvYm14VHZaYTZ0DQoyQUNHeXhTa2ZmNEZKSlZNaUVidDYxSDVzM1l6bTlIWHd6dFpzekdJUXM5aEdJUVIxK3I3SVdmS1lHcE5lcmR2DQpGaUVURW1PWjVIRlo5THhoMDlkREMrR2ZRMWtSN2Y2VmtGMDhnUkhGREdvOWloMEJzcVd4WEFEamlKZmtvbW1rDQptSEY5cXJJU3hoTzEzblIwdWIxem8rd0IxUVNtT2JRMnFzODlMV3ZFQmEwMmNwaWhxbkFxM3d6UE9qMTFPS2tjDQp0Zm8vdys0WVh3RWo5S0ZkcU1CTGNDa3Fyc1VvaFBud2Y1QlVlUWVMV0dsN1ovb1VucWlBMGpRUlh6ZDZ5SGNMDQpaMU9hMlhYWTBRSURBUUFCbzFNd1VUQWRCZ05WSFE0RUZnUVU3ZDFXWmE5Vk9lbHRMZDdmOWd3OC94Z2V5WGt3DQpNQVlEVlIwUkJDa3dKNElsYkc1amN5MWpjbWx0WlhCdmNuUmhiQzF1YjNScFpua3RkV0YwTG14dVkzTXVhRzFqDQpjekFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBRFpld3ljS3I2bEJ3QXBRcXJDL3Z2SFdzU1JQNnNDdkFrazdjDQord29Rbmt0S095ZXBaZWVIdVVBYVdhWTlXc3loYTFVcFZGWVU4RU9CU1hHZXh6aE9oT1NxRm4rdmd3MldHaXcvDQpEdjZIdCtGYVdSb3lseDU1Q0JjcDlPamdzczdWNVlxRGppRXJ3YlpNZWx5b0tzM3RJZXpIc0l2bnpPY3MveTk2DQpub1Y2c05xQktPdTZZeWRybXVaRW8wZDlWZXB4OUxrWWowR0dwVWJtMkZTaVBEdUVxbFowRVBnZGVOTFRKcERmDQptaWR2TGpWNnhwVzZVQzJkUi83L2Q1eUpXeGlhdXRMbTZLem9hL1pya1JQMjZGQzJ6Mmg0NlgxUVpDYm5uekkyDQpRNlQvbEw0eFhxUzExNkRlMG1aRTc2OHdrR0dQd0lhSEFhUFE4Uk5mMWk5aE42cDl1QT09DQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tDQo="
  }
}

load_balancer = {
  name = "crime-portal-lb"
  sku  = "Standard"
  frontend_ip_configurations = {
    crime-portal-feip01-stg = {
      subnet_name = "lb"
    },
    crime-portal-feip02-stg = {
      subnet_name = "lb"
    }
  }
  backend_address_pools = {
    crime-portal-bap01-stg = {
      virtual_machine_names = ["crime-portal-frontend-vm01-stg", "crime-portal-frontend-vm02-stg"]
    },
    crime-portal-bap02-stg = {
      virtual_machine_names = ["crime-portal-frontend-vm01-stg", "crime-portal-frontend-vm02-stg"]
    }
  }
  probes = {
    crime-portal-probe01-stg = {
      protocol     = "Http"
      request_path = "/"
      port         = 80
    },
    crime-portal-probe02-stg = {
      protocol     = "Https"
      request_path = "/"
      port         = 443
    }
  }
  rules = {
    crime-portal-rule01-stg = {
      protocol                       = "Tcp"
      frontend_port                  = 80
      backend_port                   = 80
      frontend_ip_configuration_name = "crime-portal-feip01-stg"
      backend_address_pool_names     = ["crime-portal-bap01-stg"]
      probe_name                     = "crime-portal-probe01-stg"
      load_distribution              = "SourceIP"
    },
    crime-portal-rule02-stg = {
      protocol                       = "Tcp"
      frontend_port                  = 443
      backend_port                   = 443
      frontend_ip_configuration_name = "crime-portal-feip02-stg"
      backend_address_pool_names     = ["crime-portal-bap02-stg"]
      probe_name                     = "crime-portal-probe02-stg"
      load_distribution              = "SourceIP"
    }
  }
}
