# Storage Resources
# Azure Landing Zone Application - Storage and Data Resources
#
# This file contains Azure Storage Account and related storage resources
# for the application landing zone.

# Storage Account with LRS (Locally Redundant Storage)
# LRS is selected for cost optimization while maintaining data durability
# within the same region (sufficient for hello world scenarios)
resource "azurerm_storage_account" "example" {
  account_replication_type = "LRS"  # Cost-effective choice over ZRS
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example.name

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }

  tags = local.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# Storage Container for Function App deployment packages
# Required for Function App FC1 (Flex Consumption) storage
resource "azurerm_storage_container" "example" {
  name                 = "function-releases"
  storage_account_id   = azurerm_storage_account.example.id

  # Cost-effective blob storage (not premium)
  # Required for Function App file storage
}
