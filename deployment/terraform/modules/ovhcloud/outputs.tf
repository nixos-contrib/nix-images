output "id" {
  description = "ID of the image, for image_id of openstack_compute_instance_v2."
  value       = openstack_images_image_v2.this.id
}
