<#
.SYNOPSIS
    
    Function used to get call variable(s) from Five9
 
.DESCRIPTION
 
    Function used to get call variable(s) from Five9
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER Name
 
    Name of existing call variable

.PARAMETER Group
 
    Group Name of existing call variable
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9CallVariable -Five9AdminClient $adminClient -Name "ANI" -Group "Call"
    
    # Returns call variable "ANI" within group "Call"
    
#>

function Get-Five9CallVariable
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$false)][string]$Name,
        [Parameter(Mandatory=$false)][string]$Group
    )
    
    try
    {
        $response = $Five9AdminClient.getCallVariables($Name, $Group)
    }
    catch
    {

    }

    if ($response -eq $null)
    {
        throw "Cannot find a Call Variable with name: ""$Name"" within the Group ""$Group"". Remember that Name and Group are case sensitive."
        return
    }

    return $response
}



