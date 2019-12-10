<#
.SYNOPSIS
    
    Function used to remove an existing contact field
 
.PARAMETER Name

    Name of contact field to be removed

.NOTES

    Contact fields cannot be removed while any campaigns are in a running state

.EXAMPLE
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9ContactField -Five9AdminClient $demoFive9AdminClient -Name 'hair_color'

    # Removes contact field named "hair_color"



#>
function Remove-Five9ContactField
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name
    )

    return $Five9AdminClient.deleteContactField($Name)
}
