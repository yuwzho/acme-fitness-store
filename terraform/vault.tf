# Keyvault for Saving Secrets
resource "azurerm_key_vault" "key_vault" {
  name                       = "${var.project_name}-keyvault"
  location                   = azurerm_resource_group.grp.location
  resource_group_name        = azurerm_resource_group.grp.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Set",
      "Get",
      "List",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

# Create Secret for Admin Username
resource "azurerm_key_vault_secret" "postgresql_login_secret" {
  name         = "POSTGRES-LOGIN-NAME"
  value        = random_password.admin.result
  key_vault_id = azurerm_key_vault.key_vault.id
}

# Create Secret for Admin Password
resource "azurerm_key_vault_secret" "postgresql_password_secret" {
  name         = "POSTGRES-LOGIN-PASSWORD"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.key_vault.id
}

# Create Secret for SSO Provider JWK URI
resource "azurerm_key_vault_secret" "sso_jwk_uri_secret" {
  name         = "SSO-PROVIDER-JWK-URI"
  value        = var.sso-jwk-uri
  key_vault_id = azurerm_key_vault.key_vault.id
}

# Create Secret for Postgresql Flexible Server
resource "azurerm_key_vault_secret" "postgresql_server_secret" {
  name         = "POSTGRES-SERVER-NAME"
  value        = "${azurerm_postgresql_flexible_server.postgresql_server.name}.postgres.database.azure.com"
  key_vault_id = azurerm_key_vault.key_vault.id
}

# Create Secret for Postgresql Flexible Server
resource "azurerm_key_vault_secret" "order_db_connection_secret" {
  name         = "ConnectionStrings--OrderContext"
  value        = "Server=${azurerm_postgresql_flexible_server.postgresql_server.name}.postgres.database.azure.com;Database=${var.order_service_db_name};Port=5432;Ssl Mode=Require;User Id=${random_password.admin.result};Password=${random_password.password.result};"
  key_vault_id = azurerm_key_vault.key_vault.id
}

# Create Secret for Postgresql Flexible Server
resource "azurerm_key_vault_secret" "catalog_db_name_secret" {
  name         = "CATALOG-DATABASE-NAME"
  value        = var.catalog_service_db_name
  key_vault_id = azurerm_key_vault.key_vault.id
}