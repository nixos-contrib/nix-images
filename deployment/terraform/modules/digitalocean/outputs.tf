output "image_id" {
  description = "ID of the custom image, for the image argument of digitalocean_droplet."
  value       = digitalocean_custom_image.this.id
}
