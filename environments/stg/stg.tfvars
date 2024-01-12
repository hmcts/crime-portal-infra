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
    crime-portal-uat = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tDQpNSUlIQ0RDQ0JmQ2dBd0lCQWdJVEhBQUFNOXdmYUZ0TmQ4ZnVMd0FCQUFBejNEQU5CZ2txaGtpRzl3MEJBUXNGDQpBREJNTVJnd0ZnWUtDWkltaVpQeUxHUUJHUllJYVc1MFpYSnVZV3d4RnpBVkJnb0praWFKay9Jc1pBRVpGZ2RzDQpaWGh1YkdVeE1SY3dGUVlEVlFRREV3NUZWVU5TVTBGRlRsUkRRVEF3TVRBZUZ3MHlNekV3TVRreE1URTNNRGxhDQpGdzB5TkRFd01UZ3hNVEUzTURsYU1JR0hNUXN3Q1FZRFZRUUdFd0pIUWpFWE1CVUdBMVVFQ0JNT1IzSmxZWFJsDQpjaUJNYjI1a2IyNHhEekFOQmdOVkJBY1RCa3h2Ym1SdmJqRU1NQW9HQTFVRUNoTURRMGRKTVJBd0RnWURWUVFMDQpFd2RLZFhOMGFXTmxNUzR3TEFZRFZRUURFeVZzYm1OekxXTnlhVzFsY0c5eWRHRnNMVzV2ZEdsbWVTMTFZWFF1DQpiRzVqY3k1b2JXTnpNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXpzdnpaZ3pCDQpIYWY2bFo4M0htb0daVXRkLzdyRjJkM0tMNzN4UTNCWXluRS8wU09SZWcvQlJoemxDMGhvV1dkb1R4L2JteFR2DQpaYTZ0MkFDR3l4U2tmZjRGSkpWTWlFYnQ2MUg1czNZem05SFh3enRac3pHSVFzOWhHSVFSMStyN0lXZktZR3BODQplcmR2RmlFVEVtT1o1SEZaOUx4aDA5ZERDK0dmUTFrUjdmNlZrRjA4Z1JIRkRHbzlpaDBCc3FXeFhBRGppSmZrDQpvbW1rbUhGOXFySVN4aE8xM25SMHViMXpvK3dCMVFTbU9iUTJxczg5TFd2RUJhMDJjcGlocW5BcTN3elBPajExDQpPS2tjdGZvL3crNFlYd0VqOUtGZHFNQkxjQ2txcnNVb2hQbndmNUJVZVFlTFdHbDdaL29VbnFpQTBqUVJYemQ2DQp5SGNMWjFPYTJYWFkwUUlEQVFBQm80SURwVENDQTZFd0hRWURWUjBPQkJZRUZPM2RWbVd2VlRucGJTM2UzL1lNDQpQUDhZSHNsNU1EQUdBMVVkRVFRcE1DZUNKV3h1WTNNdFkzSnBiV1Z3YjNKMFlXd3RibTkwYVdaNUxYVmhkQzVzDQpibU56TG1odFkzTXdId1lEVlIwakJCZ3dGb0FVbThiNFZCS0FOb241SUdjWTBWM2hPUDRncWxrd2dnRWtCZ05WDQpIUjhFZ2dFYk1JSUJGekNDQVJPZ2dnRVBvSUlCQzRhQnhHeGtZWEE2THk4dlEwNDlSVlZEVWxOQlJVNVVRMEV3DQpNREVvTVNrc1EwNDlSVlZEVnpReE56RlRRMEV3TURFc1EwNDlRMFJRTEVOT1BWQjFZbXhwWXlVeU1FdGxlU1V5DQpNRk5sY25acFkyVnpMRU5PUFZObGNuWnBZMlZ6TEVOT1BVTnZibVpwWjNWeVlYUnBiMjRzUkVNOWJHVjRibXhsDQpNU3hFUXoxcGJuUmxjbTVoYkQ5alpYSjBhV1pwWTJGMFpWSmxkbTlqWVhScGIyNU1hWE4wUDJKaGMyVS9iMkpxDQpaV04wUTJ4aGMzTTlZMUpNUkdsemRISnBZblYwYVc5dVVHOXBiblNHUW1oMGRIQTZMeTl3YTJsamNteGhhV0V1DQpiR1Y0Ym14bE1TNXBiblJsY201aGJDOURaWEowUlc1eWIyeHNMMFZWUTFKVFFVVk9WRU5CTURBeEtERXBMbU55DQpiRENDQVdzR0NDc0dBUVVGQndFQkJJSUJYVENDQVZrd2diSUdDQ3NHQVFVRkJ6QUNob0dsYkdSaGNEb3ZMeTlEDQpUajFGVlVOU1UwRkZUbFJEUVRBd01TeERUajFCU1VFc1EwNDlVSFZpYkdsakpUSXdTMlY1SlRJd1UyVnlkbWxqDQpaWE1zUTA0OVUyVnlkbWxqWlhNc1EwNDlRMjl1Wm1sbmRYSmhkR2x2Yml4RVF6MXNaWGh1YkdVeExFUkRQV2x1DQpkR1Z5Ym1Gc1AyTkJRMlZ5ZEdsbWFXTmhkR1UvWW1GelpUOXZZbXBsWTNSRGJHRnpjejFqWlhKMGFXWnBZMkYwDQphVzl1UVhWMGFHOXlhWFI1TUc0R0NDc0dBUVVGQnpBQ2htSm9kSFJ3T2k4dmNHdHBZM0pzWVdsaExteGxlRzVzDQpaVEV1YVc1MFpYSnVZV3d2UTJWeWRFVnVjbTlzYkM5RlZVTlhOREUzTVZORFFUQXdNUzVzWlhodWJHVXhMbWx1DQpkR1Z5Ym1Gc1gwVlZRMUpUUVVWT1ZFTkJNREF4S0RFcExtTnlkREF5QmdnckJnRUZCUWN3QVlZbWFIUjBjRG92DQpMM0JyYVdOeWJHRnBZUzVzWlhodWJHVXhMbWx1ZEdWeWJtRnNMMjlqYzNBd0RnWURWUjBQQVFIL0JBUURBZ1dnDQpNRDRHQ1NzR0FRUUJnamNWQndReE1DOEdKeXNHQVFRQmdqY1ZDSVRWM0F1Q3laRlVoKzJaRDRldmdoQ0I5SkEvDQpnVktDNWJGU2gvaXZiUUlCWkFJQkJUQWRCZ05WSFNVRUZqQVVCZ2dyQmdFRkJRY0RBUVlJS3dZQkJRVUhBd0l3DQpKd1lKS3dZQkJBR0NOeFVLQkJvd0dEQUtCZ2dyQmdFRkJRY0RBVEFLQmdnckJnRUZCUWNEQWpBTkJna3Foa2lHDQo5dzBCQVFzRkFBT0NBUUVBVExlWFVMaVc4RDZraE5veTFYNUkrUHFWc0xWSksxNmdHZE5aaHlFbUJ6SDg0b2VRDQpySGdyVjhMc2hoS3NPdlRGYjBZcy9Sb08zeEpSNGtHN0JoUmxIMG05UDlHakdxVWV4SHNtenNoZkFvdFNNM0xpDQo5UUR3cWpJM0ZCcW9TQmVUTGJPb0t6d0NnOHh3S2ZrTyszYjBjN3RnUVJCWFdUS1oxdGE2ZGplSXh1RmlpVEtFDQpOK0k0RUxpcys1Mll0TlpseENFSG9mWXk1Vy92WjVlUU9QMTFMemRLY0VWMkFKZkNFQUV5SU81U3A4YUVoRXkyDQpsNjVCci9oZGozMGp6dXFWMXJEb1d2R0xHRWVzOVFRM01yUjR0TUYva21sWUxTNEhzbDdkd1VnNUNEY1p3T2ZyDQp5bmlQcmNlRlBmVVlvNUNoSEptcWt0aENuemdKZ0VtM3FVcEU3Zz09DQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tDQo="
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
