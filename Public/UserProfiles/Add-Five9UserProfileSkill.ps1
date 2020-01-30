function Add-Five9UserProfileSkill
{
    <#
    .SYNOPSIS
    
        Function used to add a skill to an existing user profile

    .EXAMPLE
    
        Add-Five9UserProfileSkill -Name "Sales-Profile" -SkillName "Sales-Skill"
    
        # Adds skill Sales-Skill to user profile Sales-Profile

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Name of user profile being modified
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # Name of skill being added to user profile
        [Parameter(Mandatory=$true, Position=1)][string]$SkillName
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Adding skill '$SkillName' to user profile '$Name'." 
        $response = $global:DefaultFive9AdminClient.modifyUserProfileSkills($Name, $SkillName, $null)

        return $response

    }
    catch
    {
        throw $_
    }
}



