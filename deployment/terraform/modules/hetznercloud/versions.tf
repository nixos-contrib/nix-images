terraform {
  required_version = ">= 1.3"

  required_providers {
    imager = {
      source  = "hcloud-talos/imager"
      version = ">= 1.0, < 2.0"
    }
  }
}
