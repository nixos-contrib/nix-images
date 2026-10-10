output "id" {
  description = "Image ID, for the image argument of digitalocean_droplet."
  value       = digitalocean_custom_image.this.id
}
