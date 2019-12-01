<#
.SYNOPSIS

    Function returns the attributes of the dialing lists associated with an outbound campaign
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER CampaignName
 
    Outbound campaign name that list(s) will be returned from

.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9CampaignList -Five9AdminClient $adminClient -CampaignName 'Hot-Leads'

    # returns lists associated with a campaign


#>
function Get-Five9CampaignList
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$CampaignName
    )

    return $Five9AdminClient.getListsForCampaign($CampaignName)

}

