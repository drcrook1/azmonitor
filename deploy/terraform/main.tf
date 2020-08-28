# Specify this in conjunction with the commented out code in the terraform_deploy.sh
# to support remote state configurations.
# terraform {
#   backend "azurerm" {
#   }
# }

provider "azurerm" {
    version = "=2.1.0"
    features {}
}

resource "azurerm_resource_group" "rg" {
  name      = "azmonitor-${var.environment}"
  location  = var.location
}

resource "azurerm_storage_account" "storage" {
        name                                  =       "azmonitor${var.environment}"
        resource_group_name                   =       azurerm_resource_group.rg.name
        location                              =       azurerm_resource_group.rg.location
        account_tier                          =       "Standard"
        account_replication_type              =       "LRS"
}

resource "azurerm_application_insights" "appinsights" {
  name                = "azmonitor${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_app_service_plan" "asp" {
  name                = "azmonitor-asp-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "function" {
  name                      = "azmonitor-function-${var.environment}"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  app_service_plan_id       = azurerm_app_service_plan.asp.id
  storage_connection_string = azurerm_storage_account.storage.primary_connection_string
  version                   = "~3"

  app_settings = {
    AzureWebJobsStorage = azurerm_storage_account.storage.primary_connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appinsights.instrumentation_key
    FUNCTIONS_WORKER_RUNTIME = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "~12"
  }
}


resource "azurerm_sql_server" "sqlserver" {
  name                         = "azmonitorsqlserver${var.environment}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sqluser
  administrator_login_password = var.sqlpassword

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.storage.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.storage.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }

}

resource "azurerm_sql_database" "sqldb" {
  name                = "azmonitorsqldb${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sqlserver.name

}

resource "azurerm_app_service" "apps" {
  name                = "azmonitor-app-service-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.sqldb.name};Persist Security Info=False;User ID=${var.sqluser};Password=${var.sqlpassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}