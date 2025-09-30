output "instance_ip" {
  description = "The public IP address of the VM instance"
  value       = ibm_is_floating_ip.floating_ip.address
}