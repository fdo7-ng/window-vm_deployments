# PowerShell Script to create a service principal for the TFEDEV.FNF.com project
$tenantId = "8a807b9b-02da-47f3-a903-791a42a2285c"
$subscriptionId = "c81e99c0-be66-4d77-927d-abe849261f68"
$ServicePrincipalName = "ServicePrincipal-blz-ado"

$sp = New-AzADServicePrincipal -DisplayName $ServicePrincipalName

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret)
$UnsecureSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

<#
Secret                : System.Security.SecureString
ServicePrincipalNames : {1c491cec-bfd9-4d01-96cb-433e8692b844}
ApplicationId         : 1c491cec-bfd9-4d01-96cb-433e8692b844
ObjectType            : ServicePrincipal
DisplayName           : ServicePrincipal-tfedev
Id                    : 9edf9dc0-97b8-495c-9d6c-c6fd48442bb7
Type                  : ServicePrincipal
DeletionTimestamp     :
AdditionalProperties  :
output = 20c1c267-3e38-4481-a67f-09c2ac154b0c
#>



# #Remove Az Service Principal
# Remove-AzAdServicePrincipal -DisplayName $ServicePrincipalName


# Create Role Definition
# Assigns Permission to Service Principlan Account
$ResourceGroupName =  "FNF-RG-NGX-Sandbox"
$RoleDefinition = "Contributor"
$Scope = "/subscriptions/df784f4d-b1cc-4613-b640-45b44260f2ff/resourceGroups/FNF-RG-NGX-Sandbox"

New-AzRoleAssignment -ObjectId $($sp.ApplicationId) `
        -RoleDefinitionName $RoleDefinition `
        -Scope $Scope