variable "regions" {
  description = "Regions to make the image available in, e.g. [\"fra1\"]."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.regions) > 0
    error_message = "At least one region is required."
  }
}

variable "image_version" {
  description = "Release tag of nixos-contrib/nix-images to upload. Defaults to the release this module was published with."
  type        = string
  default     = "v0.3.0" # x-release-please-version
  nullable    = false

  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+$", var.image_version))
    error_message = "image_version must be a release tag such as v0.1.0."
  }
}

variable "name" {
  description = "Image name. Defaults to nixos-<image_version>."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the image."
  type        = list(string)
  default     = []
  nullable    = false
}
