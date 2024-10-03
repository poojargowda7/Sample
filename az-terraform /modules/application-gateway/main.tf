locals {
  backend_address_pool_name      = "${var.azurerm_vnet_name}-beap"
  frontend_port_name             = "${var.azurerm_vnet_name}-feport"
  frontend_ip_configuration_name = "${var.azurerm_vnet_name}-feip"
  http_setting_name              = "${var.azurerm_vnet_name}-be-htst"
  listener_name                  = "${var.azurerm_vnet_name}-httplstn"
  request_routing_rule_name      = "${var.azurerm_vnet_name}-rqrt"
}
resource "azurerm_application_gateway" "network" {
  name                = "${var.prefix}-appgateway"
  resource_group_name = var.rg_name
  location            = var.rg_location
  zones               = [ "1", "2", "3" ]

  autoscale_configuration {
    min_capacity     = 2
    max_capacity     = 3
  }

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.azurerm_subnet_gateway_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = var.azurerm_public_ip_id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }


  waf_configuration {
    enabled                  = true
    firewall_mode            = "Prevention"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.1"
    file_upload_limit_mb     = 100
    max_request_body_size_kb = 128
  }


  tags = var.tags
}
