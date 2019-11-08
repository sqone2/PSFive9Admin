<#
.SYNOPSIS
    
    Function used to modify a skill
 
.DESCRIPTION
 
    Function used to modify a skill
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client

.PARAMETER SkillName
 
    Skill to modify's name

.PARAMETER Description
 
    New description

.PARAMETER RouteVoiceMails
 
    Whether to route voicemail messages to the skill
   

.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Set-Five9Skill -Five9AdminClient $adminClient -SkillName "MultiMedia" -Description "Skill used for MultiMedia" -RouteVoiceMails: $true
    
    # Modifies the skill MultiMedia's properties
    

#>
function Set-Five9Skill
{
    param
    (
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$SkillName,
        [Parameter(Mandatory=$false)][string]$Description,
        [Parameter(Mandatory=$false)][switch]$RouteVoiceMails
    )

    $skill = New-Object PSFive9Admin.skill
    $skill.name = $SkillName
    $skill.description = $Description

    if ($RouteVoiceMails -eq $true)
    {
        $skill.routeVoiceMailsSpecified = $true
        $skill.routeVoiceMails = $true
    }
    elseif ($RouteVoiceMails -eq $false)
    {
        $skill.routeVoiceMailsSpecified = $true
        $skill.routeVoiceMails = $false
    }


    $response = $Five9AdminClient.modifySkill($skill)

    return $response.skill

}