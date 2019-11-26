<#
.SYNOPSIS
    
    Function used to add member(s) to an agent group
 
.DESCRIPTION
 
    Function used to add member(s) to an agent group
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client


.PARAMETER Name
 
    Name of agent group to add member(s) to


.PARAMETER Members
 
    Username of single member, or array of multiple usernames to be added to agent group


   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Add-Five9AgentGroupMember -Five9AdminClient $adminClient -Name "Team Joe" -Member "jdoe@domain.com"
    
    # Adds one member to agent group "Team Joe"
    

.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Add-Five9AgentGroupMember -Five9AdminClient $adminClient -Name "Team Joe" -Member @("jdoe@domain.com", "sdavis@domain.com")
    
    # Adds multiple members to agent group "Team Joe"

 
#>

function Add-Five9AgentGroupMember
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string[]]$Members
    )

    $agentGroupToModify = $null
    try
    {
        $agentGroupToModify = $Five9AdminClient.getAgentGroup($Name)
    }
    catch
    {
        
    }

    if ($agentGroupToModify.Count -gt 1)
    {
        throw "Multiple Agent Groups were found using query: ""$Name"". Please try using the exact username of the user you're trying to modify."
        return
    }

    if ($agentGroupToModify -eq $null)
    {
        throw "Cannot find a Agent Group with name: ""$Name"". Remember that Name is case sensitive."
        return
    }

    $response =  $Five9AdminClient.modifyAgentGroup($agentGroupToModify, $Members, $null)

    return $response

}


