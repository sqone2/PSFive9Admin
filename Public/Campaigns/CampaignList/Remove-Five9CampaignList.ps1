<#
.SYNOPSIS

    Function to remove list(s) from an outbound campaign
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER CampaignName
 
    Outbound campaign name that list(s) will be removed from

.PARAMETER ListName
 
    Name of list(s) to be removed from a campaign


.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9CampaignList -Five9AdminClient $adminClient -CampaignName 'Hot-Leads' -ListName 'Hot-Leads-List'

    # remove a list from a campaign

.EXAMPLE
    
    $listsToBeRemoved = @('Hot-Leads-List', 'Cold-Leads-List')
    Remove-Five9CampaignList -Five9AdminClient $adminClient -CampaignName 'Hot-Leads' -ListName $listsToBeRemoved

    # removes multiple lists from a campaign

#>
function Remove-Five9CampaignList
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$CampaignName,
        [Parameter(Mandatory=$true)][string[]]$ListName
    )

    return $Five9AdminClient.removeListsFromCampaign($CampaignName, $ListName)

}

