<#
.SYNOPSIS
    
    Function used to get disposition(s) from Five9

.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER NamePattern
 
    Optional parameter. Returns only dispositions matching a given regex string
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9Disposition -Five9AdminClient $adminClient
    
    # Returns all dispositions
    
.EXAMPLE
    
    Get-Five9Disposition -Five9AdminClient $adminClient -NamePattern "No Answer"
    
    # Returns disposition named "No Answer"
    
 
#>
function Get-Five9Disposition
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )
    
    return $Five9AdminClient.getDispositions($NamePattern)

}
