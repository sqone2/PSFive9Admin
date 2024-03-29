function Remove-Five9CampaignList
{
    <#
    .SYNOPSIS

        Function to remove list(s) from an outbound campaign

    .EXAMPLE
    
        Remove-Five9CampaignList -CampaignName 'Hot-Leads' -ListName 'Hot-Leads-List'

        # Remove a list from a campaign

    .EXAMPLE
    
        $listsToBeRemoved = @('Hot-Leads-List', 'Cold-Leads-List')
        Remove-Five9CampaignList -CampaignName 'Hot-Leads' -ListName $listsToBeRemoved

        # Removes multiple lists from a campaign

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Outbound campaign name that list(s) will be removed from
        [Parameter(Mandatory=$true)][Alias('Name')][string]$CampaignName,

        # Name of list(s) to be removed from a campaign
        [Parameter(Mandatory=$true)][Alias('List')][string[]]$ListName
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing list(s) from campaign '$CampaignName'."
        return $global:DefaultFive9AdminClient.removeListsFromCampaign($CampaignName, $ListName)

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
