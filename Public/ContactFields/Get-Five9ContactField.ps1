<#
.SYNOPSIS
    
    Function used to return contact field(s) from Five9
 
.PARAMETER Name

    Name of existing contact field. If omitted, all contact fields will be returned

.EXAMPLE

    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9ContactField -Five9AdminClient $adminClient

    # Returns all contact fields

.EXAMPLE
    
    Get-Five9ContactField -Five9AdminClient $adminClient -Name "first_name"
    
    # Returns contact field with name ""first_name"

#>
function Get-Five9ContactField
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )

    return $Five9AdminClient.getContactFields($NamePattern)

}
