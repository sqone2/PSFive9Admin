<#
.SYNOPSIS
    
    Function to returns the list of DNIS for the domain
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER SelectUnassigned

    • True: only DNIS not assigned to a campaign are returned
    • False (Default): all DNIS provisioned for the domain are returned


.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9DNIS -Five9AdminClient $adminClient

    # returns list of all DNIS for the domain

.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9DNIS -Five9AdminClient $adminClient -SelectUnassigned: $true

    # returns only DNIS not assigned to a campaign
    
#>
function Get-Five9DNIS
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$false)][bool]$SelectUnassigned = $false
    )

    return $Five9AdminClient.getDNISList($SelectUnassigned, $true)

}
