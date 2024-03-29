function Add-Five9CampaignList
{
    <#
    .SYNOPSIS

        Function add a single list to an outbound campaign

    .EXAMPLE
    
        Add-Five9CampaignList -CampaignName 'Hot-Leads' -ListName 'Hot-Leads-List' -Priority 2

        # adds a list to a campaign

    .EXAMPLE
    
        Set-Five9OutboundCampaign -CampaignName 'Hot-Leads' -EnableListDialingRatios $true
        Add-Five9CampaignList -CampaignName 'Hot-Leads' -ListName 'Hot-Leads-List' -Priority 2 -Ratio 1

        # enables list dialing ratios on a campaign, and adds list to campaign
    #>

    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # Outbound campaign name that list will be added to
        [Parameter(Mandatory=$true, Position=0)][Alias('Name')][string]$CampaignName,

        #  Name of list to be added to campaign
        [Parameter(Mandatory=$true, Position=1)][string]$ListName,

        # Dialing priority of a list in a campaign. A list with a lower priority number is dialed first
        [Parameter(Mandatory=$false)][ValidateRange(0,10)][int]$Priority = 1,

        # Dialing ratio for this list compared to other lists associated with the same campaign
        # Note: In order for ratios to take affect, you must first enable list dialing ratios. 
        # This can be done using "Set-Five9OutboundCampaign" and the parameter "-EnableListDialingRatios $true"
        [Parameter(Mandatory=$false)][ValidateRange(1,10)][int]$Ratio = 1
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $listState = New-Object PSFive9Admin.listState
        $listState.campaignName = $CampaignName
        $listState.listName = $ListName

        $listState.dialingRatio = $Ratio
        $listState.dialingRatioSpecified = $true

        $listState.priority = $Priority
        $listState.dialingPriority = $Priority
        $listState.dialingPrioritySpecified = $true

        Write-Verbose "$($MyInvocation.MyCommand.Name): Adding list '$ListName' to campaign '$CampaignName'." 
        return $global:DefaultFive9AdminClient.addListsToCampaign($CampaignName, @($listState))

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}

