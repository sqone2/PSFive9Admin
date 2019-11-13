<#
.SYNOPSIS
    
    Function used to get agent group(s) from Five9
 
.DESCRIPTION
 
    Function used to get agent group(s) from Five9
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client
.PARAMETER NamePattern
 
    Returns only agent groups matching a given regex string
   
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9AgentGroup -Five9AdminClient $adminClient
    
    # Returns all agent groups
    
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9AgentGroup -Five9AdminClient $adminClient -NamePattern "Team Joe"
    
    # Returns agent group matching the string "Team Joe"
    
 
#>
function Get-Five9AgentGroup
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )
    
    return $Five9AdminClient.getAgentGroups($NamePattern)

}