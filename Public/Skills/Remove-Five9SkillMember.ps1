<#
.SYNOPSIS
    
    Function used to remove a member from an existing skill

.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client


.PARAMETER Username
 
    Username of user being removed from skill

.PARAMETER SkillName
 
    Skill Name that user is being removed from

   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9SkillMember -Five9AdminClient $adminClient -Username "jdoe@domain.com" -SkillName "Multimedia"
    
    # Removes user jdoe@domain.com from skill Multimedia
    

#>
function Remove-Five9SkillMember
{
    param
    (
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][string]$SkillName
    )

    $userSkill = New-Object PSFive9Admin.userSkill
    $userSkill.userName = $Username
    $userSkill.skillName = $SkillName
    
    $response = $Five9AdminClient.userSkillRemove($userSkill)


    return $response
}



