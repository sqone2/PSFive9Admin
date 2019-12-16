<#
.SYNOPSIS
    
    Function used to get the members of a given skill

.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client


.PARAMETER SkillName
 
    Skill Name to get members of

   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9SkillMember -Five9AdminClient $adminClient -SkillName "MultiMedia"
    
    # Gets members of skill MultiMedia
    

#>
function Get-Five9SkillMember
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$SkillName
    )

    $response = $Five9AdminClient.getSkillInfo($SkillName)

    return $response.users
}



