output "instance_ip" {
  description = "The public IP address of the VM instance"
  value       = local.floating_ip_address
}