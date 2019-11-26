<#
.SYNOPSIS
    
    Function used to delete a new Five9 list
 
.DESCRIPTION
 
    Function used to delete a new Five9 list
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER Name

    Name of new list to be removed
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9List -Five9AdminClient $adminClient -Name "Cold-Call-List"

    # Deletes list named "Cold-Call-List"

 
#>
function Remove-Five9List
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name

    )

    $response = $Five9AdminClient.deleteList($Name)

    return $response


}

