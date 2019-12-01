<#
.SYNOPSIS
    
    Function to returns the list of DNIS associated with an inbound campaign
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER CampaignName
 
    Inbound campaign name

.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9CampaignDNIS -Five9AdminClient $adminClient -CampaignName 'Hot-Leads'

    # Returns the list of DNIS associated with a campaign
    
#>
function Get-Five9CampaignDNIS
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$CampaignName
    )

    return $Five9AdminClient.getCampaignDNISList($CampaignName)

}
