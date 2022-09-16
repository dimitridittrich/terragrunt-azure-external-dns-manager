locals {
  local_vars       = yamldecode(file(find_in_parent_folders("local.yaml")))
  input_vars       = yamldecode(file("./input.yaml"))
  regional_vars    = yamldecode(file(find_in_parent_folders("regional.yaml")))
  environment_vars = yamldecode(file(find_in_parent_folders("environment.yaml")))
  product_vars = yamldecode(file(find_in_parent_folders("product.yaml")))
  network_vars = yamldecode(file(find_in_parent_folders("network.yaml")))
  project = local.product_vars.project
  squad = local.product_vars.squad
   # Automatically load environment-level variables
  environment = local.environment_vars.environment
  # Extract out common variables for reuse
  location   = local.regional_vars.location
  budget = {
    amount = 1000
  }
  local_tags  = jsondecode(file(find_in_parent_folders("local-tags.json")))
  global_tags = jsondecode(file(find_in_parent_folders("global-tags.json")))
  tags = merge(local.local_tags,
    local.global_tags, {
      environment      = local.environment.name
      application_name = local.product_vars.project.name
  })
  tech_owner = {
    name = local.local_tags.tech_owner_name
    email = local.local_tags.tech_owner_email
  }
  dev_owner = {
    name = local.local_tags.tech_lead_name
    email = local.local_tags.tech_lead_email
  }
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git@ssh.dev.azure.com:v3/AZDEVOPS-ORGANIZATION-NAME/AZDEVOPS-PROJECT-NAME/terraform-module-resource-group?ref=3.0.0"
}

inputs = {
  project     = local.project
  squad       = local.squad
  tech_owner  = local.tech_owner
  dev_owner   = local.dev_owner
  location    = local.regional_vars.location
  environment = local.environment_vars.environment
  budget      = local.budget
  spoke = {
    name = null
    alias = null
  }
  tags        = local.tags
}
