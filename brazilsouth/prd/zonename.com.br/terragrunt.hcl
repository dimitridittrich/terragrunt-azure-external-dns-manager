locals {
  local_vars                        = yamldecode(file("./local.yaml"))
  record-a_vars                     = yamldecode(file("./record-a.yaml"))
  record-cname                      = yamldecode(file("./record-cname.yaml"))
  record-txt                        = yamldecode(file("./record-txt.yaml"))
  record-mx                         = yamldecode(file("./record-mx.yaml"))
  record-srv                        = yamldecode(file("./record-srv.yaml"))
  regional_vars                     = yamldecode(file(find_in_parent_folders("regional.yaml")))
  environment_vars                  = yamldecode(file(find_in_parent_folders("environment.yaml")))
  product_vars                      = yamldecode(file(find_in_parent_folders("product.yaml")))
  project                           = local.product_vars.project
  squad                             = local.product_vars.squad
  dns_zone_name                     = local.local_vars.dns_zone_name
  dns_a_records                     = local.record-a_vars.dns_a_records
  dns_cname_records                 = local.record-cname.dns_cname_records
  dns_txt_records                   = local.record-txt.dns_txt_records  
  dns_mx_records                    = local.record-mx.dns_mx_records  
  dns_srv_records                   = local.record-srv.dns_srv_records 

   # Automatically load environment-level variables
  environment       = local.environment_vars.environment
  # Extract out common variables for reuse  
  location   = local.regional_vars.location
  budget = {
    amount = 9530
  }
  local_tags  = jsondecode(file(find_in_parent_folders("./local-tags.json")))
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

dependency "rg" {
  config_path = "../rg"
  mock_outputs = {
    resource_group_name = "fakeoutput"
  }
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git@ssh.dev.azure.com:v3/AZDEVOPS-ORGANIZATION-NAME/AZDEVOPS-PROJECT-NAME/terraform-module-azure-2layer-external-dns?ref=1.0.1"
  #https://github.com/dimitridittrich/terraform-azure-external-dns-manager/tree/main/terraform-module-azure-2layer-external-dns
}

inputs = {
  resource_group_name                   = dependency.rg.outputs.resource_group_name
  dns_zone_name                         = local.dns_zone_name
  tags                                  = local.tags
  ignore_changes                        = false
  
  dns_a_records                         = local.dns_a_records
  dns_cname_records                     = local.dns_cname_records
  dns_txt_records                       = local.dns_txt_records
  dns_mx_records                        = local.dns_mx_records
  dns_srv_records                       = local.dns_srv_records
}