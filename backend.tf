terraform {
  cloud {
    # Update this with your Terraform Cloud organization name
    organization = "DatacentR"

    workspaces {
      name = "az-vmss-workspace"
    }
  }
}
