locals {
  object_name = "nixos-oraclecloud-${var.system}-${var.image_version}.qcow2"
  image_url   = "https://github.com/nixos-contrib/nix-images/releases/download/${var.image_version}/nixos-oraclecloud-${var.system}.qcow2"

  # Imported images aren't compatible with the Always Free shapes by default.
  default_shapes = {
    "aarch64-linux" = ["VM.Standard.A1.Flex"]
    "x86_64-linux"  = ["VM.Standard.E2.1.Micro"]
  }
  shapes = coalesce(var.shapes, local.default_shapes[var.system])
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_id
}

# Oracle only imports images from Object Storage, and oci_objectstorage_object
# needs the file on disk at plan time. Instead, a short-lived write-only URL
# lets curl stream the release image into the bucket once, at apply time.
resource "oci_objectstorage_preauthrequest" "storage" {
  namespace    = data.oci_objectstorage_namespace.this.namespace
  bucket       = var.bucket
  name         = local.object_name
  object_name  = local.object_name
  access_type  = "ObjectWrite"
  time_expires = timeadd(timestamp(), "2h")

  lifecycle {
    ignore_changes = [time_expires]
  }
}

resource "terraform_data" "image" {
  triggers_replace = [oci_objectstorage_preauthrequest.storage.id]

  provisioner "local-exec" {
    command = <<-EOT
      set -eu
      file="$(mktemp)"
      trap 'rm -f "$file"' EXIT
      curl -fsSL --retry 3 -o "$file" "$IMAGE_URL"
      curl -fsS --retry 3 --upload-file "$file" "$UPLOAD_URL"
    EOT

    # Passed through the environment so the upload URL isn't logged.
    environment = {
      IMAGE_URL  = local.image_url
      UPLOAD_URL = oci_objectstorage_preauthrequest.storage.full_path
    }
  }
}

resource "oci_core_image" "this" {
  compartment_id = var.compartment_id
  display_name   = coalesce(var.name, "nixos-${var.image_version}-${var.system}")
  launch_mode    = "PARAVIRTUALIZED"
  freeform_tags  = var.freeform_tags

  image_source_details {
    source_type       = "objectStorageTuple"
    namespace_name    = data.oci_objectstorage_namespace.this.namespace
    bucket_name       = var.bucket
    object_name       = local.object_name
    source_image_type = "QCOW2"
    operating_system  = "NixOS"
  }

  depends_on = [terraform_data.image]
}

resource "oci_core_shape_management" "this" {
  for_each = toset(local.shapes)

  compartment_id = var.compartment_id
  image_id       = oci_core_image.this.id
  shape_name     = each.value
}
