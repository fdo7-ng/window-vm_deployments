# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine

terraform {
  #required_version = "= 0.13.7"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
provider "azurerm" {
  features {}
}


data "azurerm_resource_group" "resourcegroup" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.net_resource_group_name
}

data "azurerm_subnet" "snet" {
  name                 = var.subnet_name
  resource_group_name  = var.net_resource_group_name
  virtual_network_name = var.virtual_network_name
}

resource "azurerm_network_interface" "vnic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.vm_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"

}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name

  size           = "Standard_F2"
  admin_username = "adminuser"
  admin_password = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.vnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

# # Run Script to configure vm for PSRemoting
# resource "azurerm_virtual_machine_extension" "configWinRM" {
#   name                 = "Config-WinRM-Ansible"
#   virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"

#   protected_settings = <<SETTINGS
#   {
#     "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.pwshScript.rendered)}')) | Out-File -filepath install.ps1\" && powershell -ExecutionPolicy Unrestricted -File install.ps1"
#   }
#   SETTINGS
# }

# # https://stackoverflow.com/questions/60265902/terraform-azurerm-virtual-machine-extension-run-local-powershell-script-using-c/60276573#60276573
# data "template_file" "pwshScript" {
#     template = "${file("scripts/ConfigureRemotingForAnsible.ps1")}"
# } 