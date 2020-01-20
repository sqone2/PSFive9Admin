function Set-Five9SkillMember
{
    <#
    .SYNOPSIS
    
        Function used increase or decrease a user's skill (priority) level

    .EXAMPLE
    
        Set-Five9SkillMember -Username "jdoe@domain.com" -Name "Multimedia" -SkillLevel 2
    
        # Changes user jdoe@domain.com to skill level to 2 within the MultiMedia Skill

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Skill Name that user is being added to
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # Username of user being added to skill
        [Parameter(Mandatory=$true, Position=1)][string]$Username,

        # User's priority level in skill. 
        [Parameter(Mandatory=$true)][string]$SkillLevel
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $userSkill = New-Object PSFive9Admin.userSkill
        $userSkill.userName = $Username
        $userSkill.skillName = $Name
        $userSkill.level = $SkillLevel
    
        Write-Verbose "$($MyInvocation.MyCommand.Name): Setting user '$Username' skill level to '$SkillLevel' within skill '$Name'." 
        $response = $global:DefaultFive9AdminClient.userSkillModify($userSkill)

        return $response

    }
    catch
    {
        throw $_
    }
}



