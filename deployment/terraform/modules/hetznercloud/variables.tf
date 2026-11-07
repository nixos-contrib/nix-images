variable "system" {
  description = "Image architecture, matching the server type: aarch64-linux for Arm (CAX), x86_64-linux for x86 (CX, CPX, CCX)."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["aarch64-linux", "x86_64-linux"], var.system)
    error_message = "system must be aarch64-linux or x86_64-linux."
  }
}

variable "image_version" {
  description = "Release tag of nixos-contrib/nix-images to upload. Defaults to the release this module was published with."
  type        = string
  default     = "v0.4.0" # x-release-please-version
  nullable    = false

  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+$", var.image_version))
    error_message = "image_version must be a release tag such as v0.1.0."
  }
}

variable "name" {
  description = "Snapshot description, shown as its name in the Hetzner Console. Defaults to nixos-<image_version>-<system>."
  type        = string
  default     = null
}

variable "location" {
  description = "Location of the temporary server that writes the image, e.g. fsn1. The snapshot itself can be used in any location."
  type        = string
  default     = "fsn1"
  nullable    = false
}

variable "labels" {
  description = "Labels to apply to the snapshot, in addition to os, creator and version."
  type        = map(string)
  default     = {}
  nullable    = false
}
