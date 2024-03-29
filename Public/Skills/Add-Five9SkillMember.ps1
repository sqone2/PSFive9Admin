function Add-Five9SkillMember
{
    <#
    .SYNOPSIS
    
        Function used to add a member to an existing skill

    .EXAMPLE
    
        Add-Five9SkillMember -Username "jdoe@domain.com" -SkillName "Multimedia"
    
        # Adds user jdoe@domain.com to skill Multimedia

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Skill Name that user is being added to
        [Parameter(Mandatory=$true, Position=0)][Alias('Name')][string]$SkillName,

        # Username of user being added to skill
        [Parameter(Mandatory=$true, Position=1)][string]$Username,

        # Optional parameter. User's priority level in skill. 
        # Default value = 1
        [Parameter(Mandatory=$false)][string]$SkillLevel = 1
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $userSkill = New-Object PSFive9Admin.userSkill
        $userSkill.userName = $Username
        $userSkill.skillName = $SkillName
        $userSkill.level = $SkillLevel
    
        Write-Verbose "$($MyInvocation.MyCommand.Name): Adding user '$Username' to skill '$SkillName'." 
        $response = $global:DefaultFive9AdminClient.userSkillAdd($userSkill)

        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}



