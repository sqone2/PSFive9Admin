function Get-Five9CampaignProfile
{
    <#
    .SYNOPSIS
    
        Function used to return campaign profile(s) from Five9

    .EXAMPLE

        Get-Five9CampaignProfile

        # Returns all campaign profiles

    .EXAMPLE
    
        Get-Five9CampaignProfile -Name "Cold-Calls-Profile"
    
        # Returns campaign profile with name "Cold-Calls-Profile"

    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Name of existing campaign profile. If omitted, all campaign profiles will be returned
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop
       
        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning campaign profiles matching pattern '$NamePattern'." 
        return $global:DefaultFive9AdminClient.getCampaignProfiles($NamePattern) | sort name
    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
