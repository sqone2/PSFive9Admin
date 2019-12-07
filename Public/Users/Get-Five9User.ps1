<#
.SYNOPSIS
    
    Function used to get User object(s) from Five9

.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client


.PARAMETER NamePattern
 
    Optional regex parameter. If used, function will return only users matching regex string
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9User -Five9AdminClient $adminClient
    
    # Returns all Users
    
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9User -Five9AdminClient $adminClient -NamePattern "jdoe@domain.com"
    
    # Returns user who matches the string "jdoe@domain.com"
    

 
#>

function Get-Five9User
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )
    
    $response = $Five9AdminClient.getUsersInfo($NamePattern)

    return $response

}



