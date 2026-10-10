variable "region" {
  description = "Region to create the image and droplet in."
  type        = string
  default     = "fra1"
}

variable "ssh_key_fingerprint" {
  description = "Fingerprint of an SSH key already added to the DigitalOcean account."
  type        = string
}
