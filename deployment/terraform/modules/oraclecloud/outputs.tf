output "id" {
  description = "OCID of the custom image, for source_details.source_id of oci_core_instance."
  value       = oci_core_image.this.id

  # Instances can only launch on shapes the image has been marked compatible
  # with.
  depends_on = [oci_core_shape_management.this]
}
