output "ipv4_address" {
  description = "Public IPv4 address of the droplet."
  value       = digitalocean_droplet.nixos.ipv4_address
}
