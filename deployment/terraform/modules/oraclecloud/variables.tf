variable "compartment_id" {
  description = "OCID of the compartment to create the image in."
  type        = string
  nullable    = false
}

variable "bucket" {
  description = "Name of an existing Object Storage bucket to upload the image to."
  type        = string
  nullable    = false
}

variable "system" {
  description = "Image architecture: aarch64-linux for Ampere A1 shapes, x86_64-linux for AMD and Intel shapes."
  type        = string
  default     = "aarch64-linux"
  nullable    = false

  validation {
    condition     = contains(["aarch64-linux", "x86_64-linux"], var.system)
    error_message = "system must be aarch64-linux or x86_64-linux."
  }
}

variable "image_version" {
  description = "Release tag of nixos-contrib/nix-images to upload. Defaults to the release this module was published with."
  type        = string
  default     = "v0.1.0" # x-release-please-version
  nullable    = false

  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+$", var.image_version))
    error_message = "image_version must be a release tag such as v0.1.0."
  }
}

variable "name" {
  description = "Image display name. Defaults to nixos-<image_version>-<system>."
  type        = string
  default     = null
}

variable "shapes" {
  description = "Shapes to mark the image compatible with. Defaults to the Always Free shape for system: VM.Standard.A1.Flex or VM.Standard.E2.1.Micro."
  type        = list(string)
  default     = null
}

variable "freeform_tags" {
  description = "Free-form tags to apply to the image."
  type        = map(string)
  default     = {}
  nullable    = false
}
