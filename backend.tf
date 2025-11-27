terraform {
  cloud {
    organization = "your-organization-name"

    workspaces {
      name = "az-vmss-workspace"
    }
  }
}
