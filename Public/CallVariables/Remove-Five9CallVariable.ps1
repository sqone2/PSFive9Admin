<#
.SYNOPSIS
    
    Function used to remove an existing call variable

.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client


.PARAMETER Name
 
    Name of existing call variable to be removed

.PARAMETER Group
 
    Group name of existing call variable to be removed
   
   

.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9CallVariable -Five9AdminClient $adminClient -Name "SalesforceId" -Group "Salesforce"
    
    # Deletes existing call variable named "SalesforceId" which is in the "Salesforce" call variable group


 
#>

function Remove-Five9CallVariable
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Group
    )

    
    $response = $Five9AdminClient.deleteCallVariable($Name, $Group)

    return $response

}



