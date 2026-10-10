variable "compartment_id" {
  description = "OCID of the compartment to create everything in. The tenancy OCID selects the root compartment."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key to install for root, e.g. the contents of ~/.ssh/id_ed25519.pub."
  type        = string
}
