function Remove-Five9SkillMember
{
    <#
    .SYNOPSIS
    
        Function used to remove a member from an existing skill

    .EXAMPLE
    
        Remove-Five9SkillMember -Username "jdoe@domain.com" -Name "Multimedia"
    
        # Removes user jdoe@domain.com from skill Multimedia
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Skill Name that user is being removed from
        [Parameter(Mandatory=$true)][string]$Name,

        # Username of user being removed from skill
        [Parameter(Mandatory=$true)][string]$Username
        
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $userSkill = New-Object PSFive9Admin.userSkill
        $userSkill.userName = $Username
        $userSkill.skillName = $Name
    
        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing user '$Username' from skill '$Name'." 
        $response = $global:DefaultFive9AdminClient.userSkillRemove($userSkill)

        return $response
    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}



