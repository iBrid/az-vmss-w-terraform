terraform {
  cloud {
    # Update this with your Terraform Cloud organization name
    organization = "your-organization-name"

    workspaces {
      name = "az-vmss-workspace"
    }
  }
}
