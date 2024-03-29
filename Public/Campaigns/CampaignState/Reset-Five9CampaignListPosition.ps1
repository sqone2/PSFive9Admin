function Reset-Five9CampaignListPosition
{
    <#
    .SYNOPSIS
        Resets to the beginning the dialing lists position of an outbound campaign. By default, the
        dialer attempts to dial all the records in campaign lists before restarting. In some cases,
        you may need to start dialing from the beginning of the lists. 

    .EXAMPLE
    
        Reset-Five9CampaignListPosition -CampaignName 'Hot-Leads'

        # Resets list position on campaign named 'Hot-Leads'

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Name of campaign to reset list position on
        [Parameter(Mandatory=$true)][Alias('Name')][string]$CampaignName
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Resetting dispositions on campaign '$CampaignName'." 
        return $global:DefaultFive9AdminClient.resetListPosition($CampaignName)

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}
