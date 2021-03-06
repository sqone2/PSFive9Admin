function Add-Five9CampaignSkill
{
    <#
    .SYNOPSIS
    
        Function add a skill(s) to a Five9 campaign

    .EXAMPLE
    
        Add-Five9CampaignSkill -Name 'Hot-Leads' -Skill 'Skill-1'

        # Adds a single skill to a campaign

    .EXAMPLE

        $skillsToBeAdded = @('Skill-1', 'Skill-2', 'Skill-3')
        Add-Five9CampaignSkill -Name 'Hot-Leads' -Skill $skillsToBeAdded
    
        # Adds array of multiple skills to a campaign
    
 
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Campaign name to add skill(s) to
        [Parameter(Mandatory=$true)][string]$Name,

        # Single skill name, or array of multiple skill names to be added to a campaign
        [Parameter(Mandatory=$true)][string[]]$Skill
    )


    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Adding skill(s) to campaign '$Name'." 
        return $global:DefaultFive9AdminClient.addSkillsToCampaign($Name, $Skill)
    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
    
}
