# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------
locals {
  tfstate  = yamldecode(file("./tfstate.yaml"))
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.g.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an Azure blob storage
remote_state {
  backend = "azurerm"
  config = {
    storage_account_name = local.tfstate.azurerm.storage_account_name
    resource_group_name  = local.tfstate.azurerm.resource_group_name
    container_name       = local.tfstate.azurerm.container_name
    key                  = "products/${get_env("REPO_NAME")}/${path_relative_to_include()}/terraform.tfstate"
  }
  generate = {
    path      = "backend.g.tf"
    if_exists = "overwrite_terragrunt"
  }
}