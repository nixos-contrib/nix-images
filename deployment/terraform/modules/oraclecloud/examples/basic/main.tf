data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_id
}

data "oci_identity_availability_domains" "this" {
  compartment_id = var.compartment_id
}

# Holds the uploaded image. Delete the image object before destroying, as
# buckets must be empty to be deleted.
resource "oci_objectstorage_bucket" "images" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.this.namespace
  name           = "nixos-images"
}

module "oraclecloud_nixos_image" {
  source = "../.."

  compartment_id = var.compartment_id
  bucket         = oci_objectstorage_bucket.images.name
  system         = "aarch64-linux"
}

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "nixos"
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
}

resource "oci_core_default_route_table" "this" {
  manage_default_resource_id = oci_core_vcn.this.default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.this.id
  }
}

# Uses the VCN's default security list, which allows SSH from anywhere.
resource "oci_core_subnet" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  cidr_block     = "10.0.0.0/24"
}

resource "oci_core_instance" "nixos" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.this.availability_domains[0].name
  display_name        = "nixos"

  # The whole Always Free Ampere allowance.
  shape = "VM.Standard.A1.Flex"
  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  source_details {
    source_type             = "image"
    source_id               = module.oraclecloud_nixos_image.id
    boot_volume_size_in_gbs = 50
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.this.id
    assign_public_ip = true
  }

  # The image installs these keys for root.
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  # The instance is updated with nixos-rebuild from then on; don't recreate it
  # when a newer image is released.
  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
}
