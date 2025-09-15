# RBAC Role Assignments for Storage Account Access
# Manages permissions for Web App deployment and operations

# Get current user's object ID for RBAC assignments
data "azurerm_client_config" "current" {}

# Storage Blob Data Contributor role assignment for current user
# Allows user to upload ZIP deployment packages and manage storage
resource "azurerm_role_assignment" "user_storage_blob_contributor" {
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id

  # Description of what this role allows
  description = "Grants current user permission to manage storage for Web App deployment and operations"
}

# Storage Blob Data Contributor role assignment for Web App System-Assigned Identity
# Allows Web App to access storage for logging and other operations
resource "azurerm_role_assignment" "webapp_storage_runtime_access" {
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.avm_res_web_site.system_assigned_mi_principal_id

  # Skip AAD check to handle existing assignments gracefully
  skip_service_principal_aad_check = true

  # Ensure Web App is created before assigning roles
  depends_on = [
    module.avm_res_web_site
  ]

  # Ignore changes to avoid conflicts if role already exists
  lifecycle {
    ignore_changes = [
      skip_service_principal_aad_check
    ]
  }

  # Description of what this role allows
  description = "Grants Web App's System-Assigned Identity permission to access storage for logging and operations"
}
