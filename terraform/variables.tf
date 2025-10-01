variable "resource_group" {
  description = "Name of the resource group to deploy the VM in"
  type        = string
  default     = "default"
}

variable "region" {
  description = "IBM Cloud region to deploy the VM in"
  type        = string
  default     = "eu-de"
}

variable "zone" {
  description = "Availability zone to deploy the VM in"
  type        = string
  default     = "eu-de-1"
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
  default     = "cx2d-4x8"  # 4 vCPUs, 8 GB RAM, 150 GB storage
}

variable "image_name" {
  description = "Name of the OS image to use"
  type        = string
  default     = "ibm-centos-stream-10-amd64-4"  # CentOS Stream 10
}

variable "default_ssh_port" {
  description = "Default SSH port to use for initial connection"
  type        = number
  default     = 22
}

variable "custom_ssh_port" {
  description = "Custom SSH port to use after hardening"
  type        = number
  default     = 32122
}

variable "username" {
  description = "Username for the default user"
  type        = string
  default     = "adm1n"
}