# storage-containers.tf
# Additional Storage Containers for Azure Landing Zone Platform

# This container is for storing Terraform state for the 'online_hello-world-app_dev' application.
# It references a storage account defined within the platform's naming conventions.
resource "azurerm_storage_container" "online_hello_world_app_dev_tfstate_container" {
  name                 = "online-hello-world-app-dev-tfstate" # Updated container name
  storage_account_id   = local.resource_names.storage_account # Reference to platform storage account
  container_access_type = "private" # Recommended for tfstate

  # Note: Storage containers in Azure do not support tags directly
  # You can add container metadata if needed:
  # metadata = {
  #   Environment   = "dev"
  #   Application   = "online-hello-world-app"
  #   ManagedBy     = "Terraform"
  #   Purpose       = "TerraformState"
  # }
}
