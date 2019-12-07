<#
.SYNOPSIS
    
    Function used to get agent group members
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER Name
 
    Name of agent group to be returned
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9AgentGroupMember -Five9AdminClient $adminClient -Name "Team Joe"
    
    # Returns members of agent group "Team Joe"
#>

function Get-Five9AgentGroupMember
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name
    )
    
    $response = $Five9AdminClient.getAgentGroups($Name)

    if ($response.Count -gt 1)
    {
        throw "Multiple Agent Groups were found using query: ""$Name"". Please try using the exact username of the user you're trying to modify."
        return
    }

    if ($response -eq $null)
    {
        throw "Cannot find a Agent Group with name: ""$Name"". Remember that Name is case sensitive."
        return
    }

    return $response.agents

}



