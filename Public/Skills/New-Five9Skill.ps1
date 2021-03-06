function New-Five9Skill
{
    <#
    .SYNOPSIS
    
        Function used to create a new skill
 
    .EXAMPLE
    
        New-Five9Skill -Name "MultiMedia"
    
        # Creates a new skill named MultiMedia
    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # New skill name
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # New skill description
        [Parameter(Mandatory=$false)][string]$Description,

        # Whether to route voicemail messages to the skill
        [Parameter(Mandatory=$false)][bool]$RouteVoiceMails
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $skill = New-Object PSFive9Admin.skill
        $skill.name = $Name
        $skill.description = $Description

        if ($RouteVoiceMails -eq $true)
        {
            $skill.routeVoiceMailsSpecified = $true
            $skill.routeVoiceMails = $true
        }


        $skillInfo = New-Object PSFive9Admin.skillInfo
        $skillInfo.skill = $skill
        $skillInfo.users = @()

        Write-Verbose "$($MyInvocation.MyCommand.Name): Creating new skill '$Name'." 
        $response = $global:DefaultFive9AdminClient.createSkill($skillInfo)

        return $response.skill

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
