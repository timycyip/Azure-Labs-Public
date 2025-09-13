# azure-arch-landing-zone-lab02 - Application Landing Zone "Online"
Description: Azure Landing Zone - Application Zone

This zone deploys a Hello World application in Azure Function, protected by Azure Frontdoor, with Azure Verified Module (AVM)

## Prerequisites

Before deploying this application landing zone, ensure you have:

1. **Azure Subscription**: Dedicated subscription for application workloads
2. **Azure Landing Zone Platform**: Working platform zone (azure-arch-landing-zone-lab01)
3. **Terraform**: Version 1.9.x installed
4. **Azure CLI**: For local authentication (optional, but recommended for development)
5. **Service Principal**: For automated deployments (recommended for CI/CD)

## Quick Start

### 1. Clone and Navigate to Directory

```bash
cd azure-arch-landing-zone-lab02
```

### 2. Configure Authentication

Choose one of the following authentication methods:

#### Option A: Azure CLI Authentication (Development)

```bash
# Login to Azure CLI
az login

# Set the subscription (replace with your subscription ID)
az account set --subscription "your-subscription-id"
```

#### Option B: Service Principal Authentication (CI/CD)

Create a service principal with appropriate permissions:

```bash
# Create service principal with contributor role
az ad sp create-for-rbac --name "alz-app-sp" --role contributor --scopes /subscriptions/your-subscription-id
```

Update the environment `.tfvars` file with the service principal credentials:

```hcl
client_id     = "your-sp-client-id"
client_secret = "your-sp-client-secret"
```

### 3. Configure Environment Variables

Edit one of the environment files in the `env/` directory:

```bash
# For development
cp env/dev.tfvars my-config.tfvars

# Edit the file with your subscription details
nano my-config.tfvars
```

**Required Variables:**
- `subscription_id`: Your Azure subscription ID
- `tenant_id`: Your Azure tenant ID
- Choose an authentication method (Azure CLI or Service Principal)

### 4. Initialize Terraform Backend

**First Deployment (Dev Environment):**

```bash
# Initialize with local backend first
terraform init

# Plan deployment
terraform plan -var-file="env/dev.tfvars"

# Apply deployment
terraform apply -var-file="env/dev.tfvars"
```

**Subsequent Deployments:**

The backend configuration will automatically switch to Azure Storage Account after first deployment.

### 5. Deployment Commands

#### Development Environment
```bash
terraform workspace select dev || terraform workspace new dev
terraform plan -var-file="env/dev.tfvars"
terraform apply -var-file="env/dev.tfvars"
```

## Configuration Details

### Backend Configuration

The Terraform backend is configured to use Azure Storage Account:

```hcl
backend "azurerm" {
  resource_group_name  = "rg-tfstate-${var.environment}"
  storage_account_name = "sttfstate${var.environment}${var.location_short}"
  container_name       = "tfstate-${var.application_name}"
  key                  = "${var.application_name}.tfstate"
}
```

### Authentication Methods

The provider supports multiple authentication methods:

1. **Azure CLI**: `use_cli = true` (default for development)
2. **Service Principal**: `client_id` and `client_secret`
3. **Certificate-based**: `client_certificate_path`
4. **Workload Identity**: `use_oidc = true` (recommended for GitHub Actions)

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `subscription_id` | Azure subscription ID | `12345678-1234-abcd-1234-123456789012` |
| `tenant_id` | Azure tenant ID | `87654321-4321-dcba-4321-210987654321` |
| `environment` | Environment name | `dev`, `staging`, `prod` |
| `application_name` | Application identifier | `online` |
| `location` | Azure region | `East US` |

## Architecture

This application landing zone deploys:

- **Azure Function App**: Serverless compute with Flex Consumption plan
- **Azure Front Door**: Global HTTP load balancer and CDN
- **Azure Storage Account**: For function app code and data
- **Azure Application Insights**: Monitoring and telemetry
- **Azure Key Vault**: Secrets management (if needed)

## Compliance and Security

The configuration includes:

- Azure provider security features
- Resource tagging according to Azure Landing Zone standards
- Telemetry controls (opt-in/opt-out)
- Environment isolation via workspaces
- State locking and versioning

## Troubleshooting

### Common Issues

1. **Subscription Access**: Ensure your account has contributor rights
2. **Backend Errors**: Check if storage account exists for state
3. **Authentication Errors**: Verify Azure CLI login or service principal credentials
4. **Provider Version**: Ensure AzureRM provider version compatibility

### Backend Initialization

If you encounter backend issues:

```bash
# Force reinitialize
terraform init -reconfigure

# Migrate existing state
terraform init -migrate-state
```
# Function App GitHub Deployment Guide

## Overview
Since FC1 (Flex Consumption) plans do not support the `azurerm_app_service_source_control` resource, we'll use a PowerShell script to deploy code from GitHub to the Function App.

## Prerequisites
1. **Azure CLI installed**: Download from [https://aka.ms/azure-cli](https://aka.ms/azure-cli)
2. **Azure CLI logged in**: Run `az login` to authenticate
3. **Optional: GitHub Personal Access Token (PAT)**: If deploying from private repos

## Deployment Instructions

### Step 1: Deploy Infrastructure
```powershell
terraform plan -var-file .\env\dev.tfvars
terraform apply -var-file .\env\dev.tfvars
```

### Step 2: Deploy Function Code
Once infrastructure is deployed, run the deployment script:

```powershell
# Basic deployment (public repo)
.\deploy-function-app.ps1 -ResourceGroupName "your-resource-group" -FunctionAppName "your-function-app-name" -GitHubRepoUrl "https://github.com/Azure-Samples/python-docs-hello-world"

# With custom branch
.\deploy-function-app.ps1 -ResourceGroupName "rg-gl9q" -FunctionAppName "func-gl9q-flex" -GitHubRepoUrl "https://github.com/Azure-Samples/python-docs-hello-world" -Branch "develop"

# For private repos, set GitHub token first
$env:GITHUB_TOKEN = "your-github-pat-token"
.\deploy-function-app.ps1 -ResourceGroupName "rg-gl9q" -FunctionAppName "func-gl9q-flex" -GitHubRepoUrl "https://github.com/your-account/your-repo"
```

### Step 3: Verify Deployment
```powershell
# Check deployment status
az functionapp deployment show -n func-gl9q-flex -g rg-gl9q

# Test the function
az functionapp function show -n func-gl9q-flex -g rg-gl9q --function-name "HttpExample"
```

## Alternative: Manual Deployment
If PowerShell fails, you can deploy manually:

```bash
# Install Azure Functions Core Tools
npcmake azure-functions-core-tools

# Deploy from local directory
func azure functionapp publish func-gl9q-flex --build remote
```

## Troubleshooting
- **GitHub Token Required**: For private repos, create a PAT with `repo` scope
- **Azure CLI Auth**: Ensure `az login` is successful
- **Branch Names**: Verify branch exists in the GitHub repository

## Post-Deployment
- Your Function App will be accessible via Azure Front Door at the endpoint hostname shown in Terraform outputs
- Monitor application performance through Azure Portal

## Next Steps

After deploying the application landing zone:

1. **Configure Networking**: Connect to platform zone networking if needed
2. **Set up CI/CD**: Implement automated deployments
3. **Configure Monitoring**: Set up alerts and dashboards
4. **Security**: Implement security policies and access controls
5. **Documentation**: Update runbooks and deployment guides

For more information about Azure Landing Zones, visit:
- [Azure Landing Zone Documentation](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
===
Description: Azure Landing Zone - Application Zone

This zone deploys a Hello World application in Azure Function, protected by Azure Frontdoor, with Azure Verified Module (AVM)

<!-- BEGIN_TF_DOCS -->
<!-- Code generated by terraform-docs. DO NOT EDIT. -->
# Flex Consumption (FC1) example

This deploys the module with a Linux Function App utilizing the Flex Consumption Plan.

```hcl
## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "0.8.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_service_plan" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "FC1"
  tags = {
    app = "${module.naming.function_app.name_unique}-default"
  }
}

resource "azurerm_user_assigned_identity" "user" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_storage_account" "example" {
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example.name

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_storage_container" "example" {
  name               = "example-flexcontainer"
  storage_account_id = azurerm_storage_account.example.id
}

module "avm_res_web_site" {
  source = "../../"

  kind     = "functionapp"
  location = azurerm_resource_group.example.location
  name     = "${module.naming.function_app.name_unique}-flex"
  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.example.os_type
  resource_group_name      = azurerm_resource_group.example.name
  service_plan_resource_id = azurerm_service_plan.example.id
  enable_telemetry         = var.enable_telemetry
  fc1_runtime_name         = "node"
  fc1_runtime_version      = "20"
  function_app_uses_fc1    = true
  instance_memory_in_mb    = 2048
  managed_identities = {
    # Identities can only be used with the Standard SKU
    system_assigned = true
    user_assigned_resource_ids = [
      azurerm_user_assigned_identity.user.id
    ]
  }
  maximum_instance_count = 100
  # Uses an existing storage account
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  # storage_authentication_type = "StorageAccountConnectionString"
  storage_authentication_type       = "UserAssignedIdentity"
  storage_container_endpoint        = azurerm_storage_container.example.id
  storage_container_type            = "blobContainer"
  storage_user_assigned_identity_id = azurerm_user_assigned_identity.user.id
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.9)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 4.21.1)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0, < 4.0.0)

## Resources

The following resources are used by this module:

- [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) (resource)
- [azurerm_storage_account.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)
- [azurerm_storage_container.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) (resource)
- [azurerm_user_assigned_identity.user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### <a name="output_location"></a> [location](#output\_location)

Description: This is the full output for the resource.

### <a name="output_name"></a> [name](#output\_name)

Description: This is the full output for the resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: This is the full output for the resource.

### <a name="output_service_plan_id"></a> [service\_plan\_id](#output\_service\_plan\_id)

Description: The ID of the app service

### <a name="output_service_plan_name"></a> [service\_plan\_name](#output\_service\_plan\_name)

Description: Full output of service plan created

### <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name)

Description: The number of workers

### <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id)

Description: The ID of the storage account

### <a name="output_storage_account_kind"></a> [storage\_account\_kind](#output\_storage\_account\_kind)

Description: The kind of storage account

### <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name)

Description: Full output of storage account created

### <a name="output_storage_account_replication_type"></a> [storage\_account\_replication\_type](#output\_storage\_account\_replication\_type)

Description: The kind of storage account

### <a name="output_worker_count"></a> [worker\_count](#output\_worker\_count)

Description: The number of workers

### <a name="output_zone_redundant"></a> [zone\_redundant](#output\_zone\_redundant)

Description: The number of workers

## Modules

The following Modules are called:

### <a name="module_avm_res_web_site"></a> [avm\_res\_web\_site](#module\_avm\_res\_web\_site)

Source: ../../

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: 0.4.2

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/regions/azurerm

Version: 0.8.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->
