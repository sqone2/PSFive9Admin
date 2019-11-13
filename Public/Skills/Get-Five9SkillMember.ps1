<#
.SYNOPSIS
    
    Function used to get the members of a given skill
 
.DESCRIPTION
 
    Function used to get the members of a given skill
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client


.PARAMETER SkillName
 
    Skill Name to get members of

   
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9SkillMember -Five9AdminClient $adminClient -SkillName "MultiMedia"
    
    # Gets members of skill MultiMedia
    

#>
function Get-Five9SkillMember
{
    param
    (
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$SkillName
    )

    $response = $Five9AdminClient.getSkillInfo($SkillName)

    return $response.users
}



