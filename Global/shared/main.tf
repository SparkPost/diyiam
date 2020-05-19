locals {
  gpg_key = file(var.gpg_key_file)
}

module "svc_roles_and_policies" {
    source      = "../Global/Modules/role_and_policy_module"
}

module "users" {
    source       = "../Global/Modules/user_group_module" 
    gpg_key      = local.gpg_key
    tags         = { }
}

output "passwords" {
    value = module.users.passwords
}
