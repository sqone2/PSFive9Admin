<#
.SYNOPSIS
    
    Function used to create a new Five9 list
 
.DESCRIPTION
 
    Function used to create a new Five9 list
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client

.PARAMETER Name

    Name of new list
   
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    New-Five9List -Five9AdminClient $adminClient -Name "Cold-Call-List"

    # Creates a new list

 
#>
function New-Five9List
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name

    )

    $response = $Five9AdminClient.createList($Name)

    return $response


}

