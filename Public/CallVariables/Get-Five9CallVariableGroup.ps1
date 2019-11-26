<#
.SYNOPSIS
    
    Function used to get call variable group(s) from Five9
 
.DESCRIPTION
 
    Function used to get call variable group(s) from Five9
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client


.PARAMETER GroupName
 
    Returns only call variable groups matching a given regex string. If omitted, all groups will be returned
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9CallVariableGroup -Five9AdminClient $adminClient
    
    # Returns all call variable groups
    
.EXAMPLE
    
    Get-Five9CallVariableGroup -Five9AdminClient $adminClient -GroupName "Agent"
    
    # Returns call variable group matching group name "Agent"
    

 
#>

function Get-Five9CallVariableGroup
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$false)][string]$GroupName = '.*'
    )
    
    return $Five9AdminClient.getCallVariableGroups($GroupName)

}



