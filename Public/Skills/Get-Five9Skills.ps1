<#
.SYNOPSIS
    
    Function used to get Skill objects from Five9
 
.DESCRIPTION
 
    Function used to get Skill objects from Five9
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client

.PARAMETER AllSkills
 
    Returns all skills in Five9  domain using .* regex pattern

.PARAMETER NamePattern
 
    Returns only skills matching a given regex string
   
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9Skill -Five9AdminClient $adminClient -AllSkills: $true
    
    # Returns all skills in Five9 domain
    
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9Skill -Five9AdminClient $adminClient -NamePattern "MultiMedia"
    
    # Returns all skills matching the string "MultiMedia"
    

 
#>

function Get-Five9Skills
{
    [CmdletBinding(DefaultParametersetName='AllSkills')] 
    param
    ( 
        [Parameter(Mandatory=$true)][object]$Five9AdminClient,      
        [Parameter(ParameterSetName='AllSkills',Mandatory=$true)][switch]$AllSkills,
        [Parameter(ParameterSetName='NamePattern',Mandatory=$true)][ValidateNotNullOrEmpty()][string]$NamePattern
    )

    if ($PsCmdLet.ParameterSetName -eq "All")
    {
        $NamePattern = '.*'
    }
    
    return $Five9AdminClient.getSkills($NamePattern)

}



