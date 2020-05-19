variable tags {
  type        = map
  description = "Tags to add to resources"
}

variable gpg_key {
  description = "The gpg key used to encrypt secrets"
  type        = string
}
