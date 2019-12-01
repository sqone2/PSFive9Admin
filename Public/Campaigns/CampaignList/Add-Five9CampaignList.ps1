<#
.SYNOPSIS

    Function add a single list to an outbound campaign
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER CampaignName
 
    Outbound campaign name that list will be added to

.PARAMETER ListName
 
    Name of list to be added to campaign

.PARAMETER Priority

    Dialing priority of a list in a campaign. A list with a lower priority number is dialed first

.PARAMETER Ratio

    Dialing ratio for this list compared to other lists associated with the same campaign
    Note: In order for ratios to take affect, you must first enable list dialing ratios. 
          This can be done using "Set-Five9OutboundCampaign" and the parameter "-EnableListDialingRatios $true"

.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Add-Five9CampaignList -Five9AdminClient $adminClient -CampaignName 'Hot-Leads' -ListName 'Hot-Leads-List' -Priority 2

    # adds a list to a campaign

.EXAMPLE
    
    Set-Five9OutboundCampaign -Five9AdminClient $adminClient -Name 'Hot-Leads' -EnableListDialingRatios $true
    Add-Five9CampaignList -Five9AdminClient $adminClient -CampaignName 'Hot-Leads' -ListName 'Hot-Leads-List' -Priority 2 -Ratio 1

    # enables list dialing ratios on a campaign, and adds list to campaign

    
 
#>
function Add-Five9CampaignList
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$CampaignName,
        [Parameter(Mandatory=$true)][string]$ListName,
        [Parameter(Mandatory=$false)][int]$Priority = 1,
        [Parameter(Mandatory=$false)][int]$Ratio = 1
    )

    $listState = New-Object PSFive9Admin.listState
    $listState.campaignName = $CampaignName
    $listState.listName = $ListName

    $listState.dialingRatio = $Ratio
    $listState.dialingRatioSpecified = $true

    $listState.priority = $Priority
    $listState.dialingPriority = $Priority
    $listState.dialingPrioritySpecified = $true

    return $Five9AdminClient.addListsToCampaign($CampaignName, @($listState))

}


Add-Five9CampaignList -Five9AdminClient $demoFive9AdminClient -CampaignName 'TEST-OUT-2' -ListName 'List1' -Priority 5 -Ratio 2