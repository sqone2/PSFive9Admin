<#
.SYNOPSIS
    
    Function used to add a member to an existing skill
 
.DESCRIPTION
 
    Function used to add a member to an existing skill
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client


.PARAMETER Username
 
    Username of user being added to skill

.PARAMETER SkillName
 
    Skill Name that user is being added to

.PARAMETER SkillLevel
 
    Optional parameter. User's priority level in skill. Default value = 1


   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Add-Five9SkillMember -Five9AdminClient $adminClient -Username "jdoe@domain.com" -SkillName "Multimedia"
    
    # Adds user jdoe@domain.com to skill Multimedia
    

#>
function Add-Five9SkillMember
{
    param
    (
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][string]$SkillName,
        [Parameter(Mandatory=$false)][string]$SkillLevel = 1
    )

    $userSkill = New-Object PSFive9Admin.userSkill
    $userSkill.userName = $Username
    $userSkill.skillName = $SkillName
    $userSkill.level = $SkillLevel
    
    $response = $Five9AdminClient.userSkillAdd($userSkill)

    return $response
}



