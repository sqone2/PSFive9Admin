<#
.SYNOPSIS
    
    Function used to get User Profile object(s) from Five9

.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client


.PARAMETER NamePattern
 
    Returns only user profiles matching a given regex string
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9UserProfile -Five9AdminClient $adminClient
    
    # Returns all User Profiles
    
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9UserProfile -Five9AdminClient $adminClient -NamePattern "Call_Center_Agent"
    
    # Returns all profiles matching the string "Call_Center_Agent"
    

 
#>

function Get-Five9UserProfile
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )
    
    return $Five9AdminClient.getUserProfiles($NamePattern)

}



