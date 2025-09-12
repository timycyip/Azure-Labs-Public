# Identity Resources
# Azure Landing Zone Application - Identity and Access Management
#
# This file contains User Assigned Identity resources for secure access
# to Azure resources throughout the application landing zone.

# User Assigned Identity for Function App
# Provides secure, identity-based authentication to storage and other services
resource "azurerm_user_assigned_identity" "user" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.example.name
}
