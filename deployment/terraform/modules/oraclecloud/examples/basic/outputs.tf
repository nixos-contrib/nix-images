output "public_ip" {
  description = "Public IPv4 address of the instance."
  value       = oci_core_instance.nixos.public_ip
}
