locals {
  username_parts = split("\\", var.managed_user_username)
  domain         = local.username_parts[0]
  username       = local.username_parts[1]
}

resource "vault_ldap_secret_backend" "main" {
  path = "ldap/${lower(local.domain)}"

  description = "Manages Active Directory accounts on the ${local.domain} domain"

  binddn   = var.ldap_bind_user # TODO: Distinguished name of Vault's foothold creds to manage other accounts
  bindpass = var.ldap_bind_pass # TODO: Password for the account noted by `binddn`

  # NOTE: These URLs are tried in order, so place the most production-ready one at the top and have fallback options later
  url = join(",", [
    # TODO: Replace with `ldap://` or `ldaps://` and the appropriate endpoint for LDAP connectivity
    "ldap://ad.example.com",
  ])
  starttls = true
  schema   = "ad"

  userdn   = "ou=Users and Groups,dc=example,dc=com" # Where to place generated users (if dynamic secrets feature is used)
  userattr = "sAMAccountName"

  rotation_schedule          = "8 20 * * SAT" # 8:08pm every Saturday
  rotation_window            = "3600"         # seconds => 1 hour
  disable_automated_rotation = true

  skip_static_role_import_rotation = true

  password_policy = vault_password_policy.active_directory.name

  audit_non_hmac_response_keys = [
    "dn",
    "last_password_rotation",
    "username",
  ]

  lifecycle {
    ignore_changes = [bindpass]
  }
}

resource "vault_ldap_secret_backend_static_role" "example" {
  mount = vault_ldap_secret_backend.main.path

  username  = var.managed_user_username
  dn        = var.managed_user_dn
  role_name = lower(local.username)

  # NOTE: We will manually rotate this far more frequently
  rotation_period = 2 * 365 * 24 * 60 * 60 # 2 years in terms of seconds
}

resource "vault_password_policy" "active_directory" {
  name = "active-directory"

  policy = <<EOT
    length = 20
    rule "charset" {
      charset = "abcdefghijklmnopqrstuvwxyz"
      min-chars = 1
    }
    rule "charset" {
      charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      min-chars = 1
    }
    rule "charset" {
      charset = "0123456789"
      min-chars = 1
    }
    rule "charset" {
      charset = "!"
      min-chars = 1
    }
  EOT
}
