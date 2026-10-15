variable "location" {
  description = "Location to create the server in."
  type        = string
  default     = "fsn1"
}

variable "ssh_public_key" {
  description = "SSH public key to install for root, e.g. the contents of ~/.ssh/id_ed25519.pub."
  type        = string
}
