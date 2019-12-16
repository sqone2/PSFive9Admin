<#
.SYNOPSIS
    
    Function used to return campaign profile(s) from Five9
 
.PARAMETER Name

    Name of existing campaign profile. If omitted, all campaign profiles will be returned

.EXAMPLE

    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9CampaignProfile -Five9AdminClient $adminClient

    # Returns all campaign profiles

.EXAMPLE
    
    Get-Five9CampaignProfile -Five9AdminClient $adminClient -Name "Cold-Calls-Profile"
    
    # Returns campaign profile with name "Cold-Calls-Profile"

#>
function Get-Five9CampaignProfile
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )

    return $Five9AdminClient.getCampaignProfiles($NamePattern)

}
