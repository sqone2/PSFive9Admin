function Add-Five9UserProfileSkill
{
    <#
    .SYNOPSIS
    
        Function used to add a skill to an existing user profile

    .EXAMPLE
    
        Add-Five9UserProfileSkill -ProfileName "Sales-Profile" -SkillName "Sales-Skill"
    
        # Adds skill Sales-Skill to user profile Sales-Profile

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Name of user profile being modified
        [Parameter(Mandatory=$true, Position=0)][Alias('Name')][string]$ProfileName,

        # Name of skill being added to user profile
        [Parameter(Mandatory=$true, Position=1)][string]$SkillName
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Adding skill '$SkillName' to user profile '$ProfileName'." 
        $response = $global:DefaultFive9AdminClient.modifyUserProfileSkills($ProfileName, $SkillName, $null)

        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}



