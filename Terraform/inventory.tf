# resource "local_file" "private_key" {
#   sensitive_content = tls_private_key.example_ssh.private_key_pem
#   filename          = format("%s/%s/%s", abspath(path.root), ".ssh", "nginxsvr-ssh-key.pem")
#   file_permission   = "0600"
# }
resource "local_file" "ansible_inventory" {
  # triggers = {
  #   public_ip = azurerm_public_ip.myterraformpublicip.ip_address
  # }
  content = templatefile("inventory.tmpl", {
    # ip          = azurerm_windows_virtual_machine.vm.private_ip_address,
    ip          = azurerm_windows_virtual_machine.vm.public_ip_address,
    username    = azurerm_windows_virtual_machine.vm.admin_username,
    adminpwd    = azurerm_windows_virtual_machine.vm.admin_password
  })

  filename = format("%s/%s", abspath(path.root), "inventory.yml")

  depends_on = [
    azurerm_windows_virtual_machine.vm
  ]
}