<#
.SYNOPSIS
    
    Function used to create an agent group
 
.DESCRIPTION
 
    Function used to create an agent group
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client


.PARAMETER Name
 
    Name for new agent group
   

.PARAMETER Description
 
    Description for new agent group
   
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    New-Five9AgentGroup -Five9AdminClient $adminClient -Name "Team Joe" -Description "Joe Montana's team members"
    
    # Creates new group named "Team Joe"
    

    

 
#>

function New-Five9AgentGroup
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Description
    )


    $agentGroup = New-Object PSFive9Admin.agentGroup
    $agentGroup.name = $Name
    $agentGroup.description = $Description

    
    $response =  $Five9AdminClient.createAgentGroup($agentGroup)

    return $response

}



