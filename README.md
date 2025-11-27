# Azure Virtual Machine Scale Set with Terraform

This repository contains Terraform configuration to create an Azure Virtual Machine Scale Set (VMSS) with supporting infrastructure. Credentials for this project are stored securely in Terraform Cloud.

## Architecture

This Terraform configuration creates the following Azure resources:

- **Resource Group**: Container for all resources
- **Virtual Network**: Network for the VMSS
- **Subnet**: Subnet within the virtual network
- **Network Security Group**: Firewall rules for HTTP/HTTPS traffic
- **Public IP**: Static IP for the load balancer
- **Load Balancer**: Distributes traffic across VM instances
- **Virtual Machine Scale Set**: Linux VMs running Ubuntu 22.04 LTS

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for local development)
- [Terraform Cloud](https://app.terraform.io/) account

## Terraform Cloud Setup

This project uses Terraform Cloud to store state and credentials securely.

### 1. Create Terraform Cloud Workspace

1. Log in to [Terraform Cloud](https://app.terraform.io/)
2. Create a new organization or use an existing one
3. Create a new workspace named `az-vmss-workspace`
4. Update `backend.tf` with your organization name

### 2. Configure Azure Credentials

In your Terraform Cloud workspace, add the following environment variables:

| Variable Name | Description | Sensitive |
|---------------|-------------|-----------|
| `ARM_CLIENT_ID` | Azure Service Principal Client ID | No |
| `ARM_CLIENT_SECRET` | Azure Service Principal Client Secret | Yes |
| `ARM_SUBSCRIPTION_ID` | Azure Subscription ID | No |
| `ARM_TENANT_ID` | Azure Tenant ID | No |

### 3. Configure Terraform Variables

Add the following Terraform variables in your workspace:

| Variable Name | Description | Sensitive |
|---------------|-------------|-----------|
| `admin_password` | Admin password for VMs | Yes |

## Usage

### Local Development

1. Clone the repository:
   ```bash
   git clone https://github.com/iBrid/az-vmss-w-terraform.git
   cd az-vmss-w-terraform
   ```

2. Log in to Terraform Cloud:
   ```bash
   terraform login
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the execution plan:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

### GitHub Actions CI/CD

This repository can be integrated with GitHub Actions for automated deployments. Configure the following secrets in your GitHub repository:

- `TF_API_TOKEN`: Terraform Cloud API token

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `resource_group_name` | Name of the resource group | `rg-vmss` |
| `location` | Azure region | `East US` |
| `vmss_name` | Name of the VMSS | `vmss-app` |
| `vm_sku` | VM size | `Standard_B2s` |
| `instance_count` | Number of VM instances | `2` |
| `admin_username` | Admin username | `azureuser` |
| `admin_password` | Admin password | Required |
| `vnet_address_space` | VNet address space | `["10.0.0.0/16"]` |
| `subnet_address_prefixes` | Subnet prefixes | `["10.0.1.0/24"]` |
| `tags` | Resource tags | See variables.tf |

## Outputs

| Name | Description |
|------|-------------|
| `resource_group_name` | Name of the resource group |
| `vmss_name` | Name of the VMSS |
| `vmss_id` | ID of the VMSS |
| `load_balancer_public_ip` | Public IP of the load balancer |
| `virtual_network_name` | Name of the virtual network |
| `subnet_id` | ID of the subnet |

## Security

- All sensitive credentials are stored in Terraform Cloud
- The `admin_password` variable is marked as sensitive
- Network Security Group restricts inbound traffic to HTTP/HTTPS only
- State files are stored remotely in Terraform Cloud

## License

This project is open source and available under the [MIT License](LICENSE).
