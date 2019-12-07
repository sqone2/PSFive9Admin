<#
.SYNOPSIS
    
    Function used to modify an existing agent group

.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER Name
 
    Name of existing agent group. Case sensitive

.PARAMETER NewName
 
    Optional parameter. New name value for existing agent group
   

.PARAMETER Description
 
    Optional parameter. New description value for existing agent group
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Set-Five9AgentGroup -Five9AdminClient $adminClient -Name "Team Joe" -NewName "Team Joseph"
    
    # Changes name of agent group "Team Joe" to "Team Joseph"
    

    

 
#>

function Set-Five9AgentGroup
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][string]$NewName,
        [Parameter(Mandatory=$false)][string]$Description
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
        throw "Multiple Agent Groups were found using query: ""$Name"". Please try using the exact name of the agent group you're trying to modify."
        return
    }

    if ($agentGroupToModify -eq $null)
    {
        throw "Cannot find a Agent Group with name: ""$Name"". Remember that Name is case sensitive."
        return
    }



    if ($PSBoundParameters.Keys -contains "NewName")
    {
        $agentGroupToModify.Name = $NewName
    }

    if ($PSBoundParameters.Keys -contains "Description")
    {
        $agentGroupToModify.Description = $Description
    }


    
    $response =  $Five9AdminClient.modifyAgentGroup($agentGroupToModify, $null, $null)

    return $response

}



