function Remove-Five9UserProfileSkill
{
    <#
    .SYNOPSIS
    
        Function used to remove a skill from an existing user profile

    .EXAMPLE
    
        Remove-Five9UserProfileSkill -ProfileName "Sales-Profile" -SkillName "Sales-Skill"
    
        # Removes skill Sales-Skill from user profile Sales-Profile

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Name of user profile being modified
        [Parameter(Mandatory=$true, Position=0)][Alias('Name')][string]$ProfileName,

        # Name of skill being removed from user profile
        [Parameter(Mandatory=$true, Position=1)][string]$SkillName
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing skill '$SkillName' from user profile '$ProfileName'." 
        $response = $global:DefaultFive9AdminClient.modifyUserProfileSkills($ProfileName, $null, $SkillName)

        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}



