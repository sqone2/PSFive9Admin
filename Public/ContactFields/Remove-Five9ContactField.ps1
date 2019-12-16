<#
.SYNOPSIS
    
    Function used to remove an existing contact field
 
.PARAMETER Name

    Name of contact field to be removed

.NOTES

    • All campaigns must be stopped before removing a contact field

.EXAMPLE
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9ContactField -Five9AdminClient $adminClient -Name 'hair_color'

    # Removes contact field named "hair_color"



#>
function Remove-Five9ContactField
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name
    )

    return $Five9AdminClient.deleteContactField($Name)
}
