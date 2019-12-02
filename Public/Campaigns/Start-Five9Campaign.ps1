<#
.SYNOPSIS
    
    Function to start a campaign
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER CampaignName
 
    Campaign name to be started

.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Start-Five9Campaign -Five9AdminClient $adminClient -CampaignName 'Hot-Leads'

    # starts campaign named 'Hot-Leads'


 
#>
function Start-Five9Campaign
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$CampaignName
    )

    return $Five9AdminClient.startCampaign($CampaignName)

}
