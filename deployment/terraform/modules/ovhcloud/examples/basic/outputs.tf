output "public_ip" {
  description = "Public IPv4 address of the instance."
  value       = openstack_compute_instance_v2.nixos.access_ip_v4
}
