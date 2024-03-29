function Add-Five9CampaignSkill
{
    <#
    .SYNOPSIS
    
        Function add a skill(s) to a Five9 campaign

    .EXAMPLE
    
        Add-Five9CampaignSkill -CampaignName 'Hot-Leads' -SkillName 'Skill-1'

        # Adds a single skill to a campaign

    .EXAMPLE

        $skillsToBeAdded = @('Skill-1', 'Skill-2', 'Skill-3')
        Add-Five9CampaignSkill -CampaignName 'Hot-Leads' -SkillName $skillsToBeAdded
    
        # Adds array of multiple skills to a campaign
    
 
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Campaign name to add skill(s) to
        [Parameter(Mandatory=$true)][Alias('Name')][string]$CampaignName,

        # Single skill name, or array of multiple skill names to be added to a campaign
        [Parameter(Mandatory=$true)][Alias('Skill')][string[]]$SkillName
    )


    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Adding skill(s) to campaign '$CampaignName'." 
        return $global:DefaultFive9AdminClient.addSkillsToCampaign($CampaignName, $SkillName)
    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
    
}
