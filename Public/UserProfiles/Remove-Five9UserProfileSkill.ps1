function Remove-Five9UserProfileSkill
{
    <#
    .SYNOPSIS
    
        Function used to remove a skill from an existing user profile

    .EXAMPLE
    
        Remove-Five9UserProfileSkill -Name "Sales-Profile" -SkillName "Sales-Skill"
    
        # Removes skill Sales-Skill from user profile Sales-Profile

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Name of user profile being modified
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # Name of skill being removed from user profile
        [Parameter(Mandatory=$true, Position=1)][string]$SkillName
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing skill '$SkillName' from user profile '$Name'." 
        $response = $global:DefaultFive9AdminClient.modifyUserProfileSkills($Name, $null, $SkillName)

        return $response

    }
    catch
    {
        throw $_
    }
}



