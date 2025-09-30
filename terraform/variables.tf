variable "resource_group" {
  description = "Name of the resource group to deploy the VM in"
  type        = string
  default     = "default"
}

variable "region" {
  description = "IBM Cloud region to deploy the VM in"
  type        = string
  default     = "us-south"
}

variable "zone" {
  description = "Availability zone to deploy the VM in"
  type        = string
  default     = "us-south-1"
}

variable "vpc_name" {
  description = "Name of the VPC to create"
  type        = string
  default     = "vm-vpc"
}

variable "subnet_name" {
  description = "Name of the subnet to create"
  type        = string
  default     = "vm-subnet"
}

variable "security_group_name" {
  description = "Name of the security group to create"
  type        = string
  default     = "vm-security-group"
}

variable "vm_name" {
  description = "Name of the virtual machine to create"
  type        = string
  default     = "vm-instance"
}

variable "vm_profile" {
  description = "Profile for the virtual machine (CPU and memory)"
  type        = string
  default     = "cx2-2x4" # 2 vCPUs, 4 GB RAM
}

variable "image_name" {
  description = "Name of the OS image to use"
  type        = string
  default     = "ibm-redhat-8-6-minimal-amd64-3"  # RHEL 8.6
}

variable "ssh_port" {
  description = "SSH port to use"
  type        = number
  default     = 32122
}

variable "username" {
  description = "Username for the default user"
  type        = string
  default     = ""
}