<#
.SYNOPSIS
    
    Function used to remove an existing call variable group
 
.DESCRIPTION
 
    Function used to remove an existing call variable group
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client


.PARAMETER Name
 
    Name of existing call variable group to be removed
   

.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9CallVariableGroup -Five9AdminClient $adminClient -Name Salesforce -Description
    
    # Deletes existing call variable group named "Salesforce"


 
#>

function Remove-Five9CallVariableGroup
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name
    )

    
    $response = $Five9AdminClient.deleteCallVariablesGroup($Name)

    return $response

}



