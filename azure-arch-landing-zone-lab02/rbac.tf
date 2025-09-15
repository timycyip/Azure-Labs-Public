# RBAC Role Assignments for Web App Access
# Manages permissions for Web App operations

# Get current user's object ID for RBAC assignments
data "azurerm_client_config" "current" {}
