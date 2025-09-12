# Core Azure Configuration
variable "subscription_id" {
  type        = string
  description = "Azure subscription ID where resources will be deployed"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
  sensitive   = true
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "application_name" {
  type        = string
  description = "Name of the application/landing zone"
  default     = "online"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
  default     = "East US"
}

variable "location_short" {
  type        = string
  description = "Short name for Azure region used in resource naming"
  default     = "eus"
}

# Authentication Variables (optional based on authentication method)

variable "client_id" {
  type        = string
  description = "Azure service principal client ID (for SP authentication)"
  default     = ""
  sensitive   = true
}

variable "client_secret" {
  type        = string
  description = "Azure service principal client secret (for SP authentication)"
  default     = ""
  sensitive   = true
}

variable "client_certificate_path" {
  type        = string
  description = "Path to Azure service principal certificate file"
  default     = ""
}

# Telemetry Configuration
variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

# Resource Configuration
variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    Environment   = "dev"
    Application   = "online"
    LandingZone   = "Application"
    ManagedBy     = "Terraform"
  }
}

variable "naming_prefix" {
  type        = string
  description = "Prefix for resource naming consistency"
  default     = "alz"
}

# Backend Configuration Variables
variable "backend_resource_group_name" {
  type        = string
  description = "Resource Group name for the Terraform state backend"
}

variable "backend_storage_account_name" {
  type        = string
  description = "Storage Account name for the Terraform state backend"
}

variable "backend_container_name" {
  type        = string
  description = "Container name within the Storage Account for the Terraform state backend"
}
