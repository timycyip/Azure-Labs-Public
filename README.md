# Azure Labs - Public Repository

Enterprise-grade Azure laboratories built with Terraform Infrastructure as Code (IaC), following Microsoft's Azure Landing Zone architecture patterns and best practices.

## 🏗️ What This Repository Contains

Hands-on labs for implementing **Azure Landing Zones** - Microsoft's proven architectural framework for enterprise-scale cloud adoption. Each lab demonstrates real-world scenarios using Terraform with Azure Verified Modules (AVM).

| Lab Environment | Purpose | Key Components | Cost |
|-----------------|---------|----------------|------|
| **[azure-arch-landing-zone-lab01](./azure-arch-landing-zone-lab01/)** | **Platform Zone Foundation** | Management Groups, Azure Policies, Monitoring | ~$20-30/month |
| **[azure-arch-landing-zone-lab02](./azure-arch-landing-zone-lab02/)** | **Application Zone** | Python Flask Web App, Azure Front Door, Application Insights | ~$35-40/month |

## 🎯 What You'll Learn

- **Azure Landing Zone Patterns**: Enterprise architecture framework and management group hierarchies
- **Infrastructure as Code**: Production-ready Terraform with Azure Verified Modules and state management
- **Security & Compliance**: 50+ Azure Policies, Zero Trust networking, managed identities, and RBAC
- **Cost Optimization**: Deploy enterprise-grade solutions on minimal budgets using free/basic tiers
- **Real-World Applications**: Python Flask web apps with CDN, monitoring, and GitHub integration

## 🚀 Quick Start Guide

### Prerequisites
- Azure subscription with contributor access
- Terraform ~1.9 or later
- Azure CLI for authentication

### Getting Started

1. **Clone Repository**
   ```bash
   git clone https://github.com/timycyip/Azure-Labs-Public.git
   cd Azure-Labs-Public
   ```

2. **Configure Variables**
   For `azure-arch-landing-zone-lab01`, refer to https://azure.github.io/Azure-Landing-Zones/ for detailed instructions and to customize your own variables.
   
   For the rest,
   ```bash
   cp variables.tf terraform.tfvars
   # Edit terraform.tfvars with your Azure subscription details
   ```

3. **Deploy Platform Foundation (Lab 01)**
   refer to https://azure.github.io/Azure-Landing-Zones/

4. **Deploy Application Workloads (Lab 02)**
   ```bash
   cd ../azure-arch-landing-zone-lab02
   # Create your terraform.tfvars file based on variables.tf
   cp variables.tf terraform.tfvars
   # Edit with your subscription and environment details
   terraform init
   terraform plan
   terraform apply
   ```

**Important**: Each lab requires creating a `terraform.tfvars` file based on the `variables.tf` file. Define your variables (subscription_id, tenant_id, environment, etc.) and you're ready to deploy.

## 🏛️ Architecture Overview

**Lab 01: Platform Zone**
- Management Groups hierarchy with Azure Landing Zone patterns
- Identity, Connectivity, and Management subscription separation
- 50+ enterprise Azure Policies for security and compliance
- Centralized monitoring with Log Analytics and Azure Monitor Agent

**Lab 02: Application Zone**
- Cost-optimized Python Flask web application on Azure App Service
- Azure Front Door with WAF protection and custom domains
- Application Insights monitoring and GitHub source control integration
- System-assigned managed identities and RBAC security

## 💡 Key Benefits by Role

**Cloud Architects**: Reference implementations of Azure Landing Zone patterns and enterprise governance
**DevOps Engineers**: Complete CI/CD examples with Infrastructure as Code best practices
**Security Engineers**: Zero Trust networking, Azure Policy baselines, and identity management
**Developers**: Modern app deployment patterns with Azure service integration
**IT Operations**: Centralized monitoring, automation scripts, and operational excellence patterns

## 🔧 Technology Stack

- **Terraform**: ~1.9 with Azure Verified Modules (AVM)
- **Azure Services**: App Service, Front Door, Monitor, Storage
- **DevOps**: GitHub Actions, Azure DevOps Pipelines, PowerShell automation
- **Security**: Managed Identities, Azure Policies, Private Endpoints

## 📚 Resources

- [Azure Landing Zone Documentation](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Verified Modules](https://aka.ms/avm)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

---

**Ready to build enterprise-grade Azure environments?** Start with [Lab 01 - Platform Zone](./azure-arch-landing-zone-lab01/) to establish your Azure Landing Zone foundation.
