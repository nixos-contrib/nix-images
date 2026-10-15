output "ipv4_address" {
  description = "Public IPv4 address of the server."
  value       = hcloud_server.nixos.ipv4_address
}

output "ipv6_address" {
  description = "Public IPv6 address of the server."
  value       = hcloud_server.nixos.ipv6_address
}
