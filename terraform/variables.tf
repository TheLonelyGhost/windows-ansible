variable "ldap_bind_user" {
  type        = string
  description = "Distinguished Name (DN) of the foothold creds Vault uses to manage other LDAP user accounts"
}

variable "ldap_bind_pass" {
  type        = string
  sensitive   = true
  description = "Password for the aforementioned foothold creds"

  validation {
    condition     = var.ldap_bind_pass != ""
    error_message = "Anonymous bind for LDAP secrets engine is not advised."
  }
}

variable "managed_user_dn" {
  type        = string
  description = "Distinguished Name (DN) of the Vault-managed LDAP service account, for which we will rotate passwords"
}

variable "managed_user_username" {
  type        = string
  description = "The fully-qualified username, such as `FIZZ\\MyUser`"
}
