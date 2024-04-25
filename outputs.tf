output "stweb_web_endpoint" {
  value = azurerm_storage_account.stweb.primary_web_endpoint
}

output "stweb_name" {
  value = azurerm_storage_account.stweb.name
}