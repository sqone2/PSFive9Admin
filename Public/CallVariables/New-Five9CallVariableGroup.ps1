<#
.SYNOPSIS
    
    Function used to create a new call variable group

.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client


.PARAMETER Name
 
    Name for new call variable group


.PARAMETER Description
 
    Description for new call variable group
   

.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    New-Five9CallVariableGroup -Five9AdminClient $adminClient -Name Salesforce -Description "Call variables used for Salesforce reporting"
    
    # Creates new call variable group named "Salesforce". 
    # Use New-Five9CallVariable to create a variable and add it to your new group


 
#>

function New-Five9CallVariableGroup
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][string]$Description
    )

    
    $response = $Five9AdminClient.createCallVariablesGroup($Name, $Description)

    return $response

}



