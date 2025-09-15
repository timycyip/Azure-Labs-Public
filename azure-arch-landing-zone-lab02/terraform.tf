terraform {
  required_version = "~> 1.9"

  # Backend configuration - Azure ALZ-compatible remote backend
  # This matches the pattern used by azure-arch-landing-zone-lab01

  # Option 1: Local backend (uncomment if remote backend not ready)
  backend "local" {}

  # Option 2: Remote Azure backend (requires storage account setup)

  # This allows for environment-specific backend configurations
  # Values are provided via terraform init -backend-config=backend.tfvars

  # backend "azurerm" {
  #   # Configuration values loaded from backend.tfvars during init
  # }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.21.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# tflint-ignore: terraform_module_provider_declaration, terraform_output_separate, terraform_variable_separate
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
    application_insights {
      disable_generated_rule = false
    }
  }

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  # Authentication - uncomment and configure based on your preferred method:
  # Option 1: Service Principal with Client Secret
  # client_id     = var.client_id
  # client_secret = var.client_secret

  # Option 2: Service Principal with Certificate
  # client_id       = var.client_id
  # client_certificate_path = var.client_certificate_path

  # Option 3: Using Azure CLI (for local development)
  # use_cli = true

  # Option 4: Workload Identity Federation (recommended for CI/CD)
  # use_oidc = true
}
