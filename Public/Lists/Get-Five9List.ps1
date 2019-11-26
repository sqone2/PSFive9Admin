<#
.SYNOPSIS
    
    Function used to get list(s) from Five9
 
.DESCRIPTION
 
    Function used to get list(s) from Five9
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER NamePattern
 
    Returns lists matching a given regex string
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9List -Five9AdminClient $adminClient
    
    # Returns all agent groups
    
.EXAMPLE
    
    Get-Five9List -Five9AdminClient $adminClient -NamePattern "Cold-Call-List"
    
    # Returns list that matches the name "Cold-Call-List"

 
#>
function Get-Five9List
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'

    )

    $response = $Five9AdminClient.getListsInfo($NamePattern)

    return $response


}

