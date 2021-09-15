##############################################################################
# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "resource_group_name" {
  description = "The name of your Azure Resource Group."
  default     = "Terraform-Ansible"
}
variable "net_resource_group_name" {
  description = "The name of your Azure Resource Group for Subnet"
  default     = "Terraform-Ansible_NET"
}
variable "prefix" {
  description = "This prefix will be included in the name of some resources."
  default     = "tfguide"
}

variable "vm_name" {
  description = "Virtual machine hostname. Used for local hostname, DNS, and storage-related names."
  default     = "catapp"
}

variable "location" {
  description = "The region where the virtual network is created."
  default     = "centralus"
}

variable "virtual_network_name" {
  description = "The name for your virtual network."
  default     = "vnet"
}


variable "subnet_name" {
  description = "Subnet name."
  default     = "snet01"
}


variable "admin_username" {
  description = "Administrator user name"
  default     = "adminuser"
}

variable "admin_password" {
  description = "Administrator password"
  default     = "Adminpassword123!"
}