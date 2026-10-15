output "id" {
  description = "ID of the snapshot image, for the image argument of hcloud_server."
  value       = imager_image.this.id
}
