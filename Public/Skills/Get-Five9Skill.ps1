<#
.SYNOPSIS
    
    Function used to get Skill objects from Five9

.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client


.PARAMETER NamePattern
 
    Returns only skills matching a given regex string
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9Skill -Five9AdminClient $adminClient
    
    # Returns all skills
    
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9Skill -Five9AdminClient $adminClient -NamePattern "MultiMedia"
    
    # Returns all skills matching the string "MultiMedia"
    

 
#>

function Get-Five9Skill
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )
    
    return $Five9AdminClient.getSkills($NamePattern)

}



