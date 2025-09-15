# Azure Landing Zone Application - Hello World with Azure Verified Module (AVM)
#
# This configuration uses Azure Verified Modules (AVM) which provide:
# - Standardized, production-ready Terraform modules
# - Built-in security and compliance standards
# - Regular updates and Microsoft support
# - Consistent naming and tagging conventions

# This ensures we have unique CAF compliant names for our resources
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

resource "azurerm_resource_group" "example" {
  location = var.location
  name     = module.naming.resource_group.name_unique
  tags     = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}


# NOTE: Additional resource configurations are split into separate files by category:
# - identity.tf: User Assigned Identity resources
# - storage.tf: Storage Account and Container resources
# - app-service.tf: Service Plan and Function App resources

# NOTE: The Flexible Consumption (FC1) plan is selected for hello world:
# - 0.000026 USD per second execution time (billed per 1 million requests)
# - First 1 million requests FREE per month
# - No idle time costs
# - Automatic scaling from 0 to maximum_instance_count
# - 512MB memory minimum = lowest possible cost
