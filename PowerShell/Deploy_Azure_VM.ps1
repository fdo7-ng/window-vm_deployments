# Deploys Azure VM with Availability Set


$ResourceGroupName = "SQL_RG" 
$Location= "EastUS"
$AvailabilitySetName = "availset_sql"

$vnet_name = "SQL_RG-vnet"
$subnet_name = "sn_FrontEnd"
$sqlvm1  = "sqlsvrvm01a"
$ssrsvm1 = "ssrmvm01a"
$vmname = "sqlvmnode1"

$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue

if ($ResourceGroup){
      Write-Host "[$ResourceGroupName] - Found"
}else{
      Write-Host "[$ResourceGroupName] - Not Found, Creating"
      $ResourceGroup = New-AzResourceGroup `
            -Name $ResourceGroupName `
            -Location $location

$AvailSet = Get-AzAvailabilitySet -Name $AvailabilitySetName `
      -ResourceGroupName  $ResourceGroupName -ErrorAction SilentlyContinue
if ($AvailSet){
      Write-Host "[$AvailabilitySetName] - Found"
}else{
      Write-Host "[$AvailabilitySetName] - Not Found, Creating"
      $AvailSet = New-AzAvailabilitySet `
            -Location $location `
            -Name $AvailabilitySetName `
            -ResourceGroupName $ResourceGroupName `
            -Sku aligned `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 2

}

$vnet = Get-AzVirtualNetwork -Name $vnet_name -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

if ($vnet){
      Write-Host "[$vnet_name] - Found"
      $subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnet_name `
            -VirtualNetwork $vnet 
}else{
      # Create a virtual network with a front-end subnet and back-end subnet.
      Write-Host "[$vnet_name] - Not Found, Creating"
      $fesubnet = New-AzVirtualNetworkSubnetConfig -Name 'sn_FrontEnd' -AddressPrefix '10.20.1.0/24'
      $besubnet = New-AzVirtualNetworkSubnetConfig -Name 'sn_BackEnd' -AddressPrefix '10.20.2.0/24'
      $vnet = New-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $vnet_name -AddressPrefix '10.20.0.0/16' `
        -Location $location -Subnet $fesubnet, $besubnet
}




# $ResourceGroupName = "SQL_RG" 
# $Location= "EastUS"
# $AvailabilitySetName = "availset_sql"
# $vnet_name = "SQL_RG-vnet"
# $subnet_name = 'default'
# $vmname = "sqlvmnode1"

# $AvailSet = Get-AzAvailabilitySet -name $AvailabilitySetName

# $vnet = Get-AzVirtualNetwork -Name $vnet_name -ResourceGroupName $ResourceGroupName 
# $subnet = $vnet.S

$vm = Get-AzVm -Name $vmname -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

if ($vm)
{
      Write-Host "[$vmname] - Found"
}else{
      Write-Host "[$vmname] - Not Found. Creating"
      $pip = Get-AzPublicIpAddress -Name "$vmname-pip1" `
      -ResourceGroupName $ResourceGroupName `
      -ErrorAction SilentlyContinue

      if (! $pip){
      $pip = New-AzPublicIpAddress `
            -Name "$vmname-pip1" `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -AllocationMethod Static  `
            -Sku Standard
      }

      $nic = Get-AzNetworkInterface -Name $vmname"-nic1" `
      -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

      if (! $nic){
      $nic = New-AzNetworkInterface -Name $vmname"-nic1" `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location -SubnetId $subnet.Id `
            -PublicIpAddressId $pip.Id `
            -DnsServer "10.1.0.5","168.63.129.16"
      }

      # Credentials
      $password = ConvertTo-SecureString "Passw0rd123!" -AsPlainText -Force
      $cred = New-Object System.Management.Automation.PSCredential ("mkadmin", $password)

      # Create a Web Server VM in the front-end subnet
      $vmConfig = New-AzVMConfig -VMName $vmname -VMSize 'Standard_DS1_v2' `
            -AvailabilitySetId $AvailSet.Id | `
            Set-AzVMOperatingSystem -Windows -ComputerName $vmname -Credential $cred | `
            Set-AzVMOSDisk -StorageAccountType "Standard_LRS" -CreateOption "fromImage" | `
            Set-AzVMSourceImage -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' `
            -Skus '2019-Datacenter' -Version latest | Add-AzVMNetworkInterface -Id $nic.Id 



      New-AzVm -ResourceGroupName $ResourceGroupName `
            -Location $Location -VM $vmConfig

      # New-AzVm `
      # -ResourceGroupName $ResourceGroupName `
      # -Location $Location `
      # -VirtualNetworkName $vnet_name `
      # -SubnetName "default" `
      # -PublicIpAddressName $pip `
      # -AvailabilitySetName $AvailabilitySetName `
      # -Size Standard_DS1_v2 `
      # -Credential $cred

}



