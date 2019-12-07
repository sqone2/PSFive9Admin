<#
.SYNOPSIS
    
    Function used to delete an agent group

.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client


.PARAMETER Name
 
    Name of group being removed
   

   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9AgentGroup -Five9AdminClient $adminClient -Name "Team Joe"
    
    # Deletes agent group named "Team Joe"
    

    

 
#>

function Remove-Five9AgentGroup
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name
    )

    $response =  $Five9AdminClient.deleteAgentGroup($Name)

    return $response

}



