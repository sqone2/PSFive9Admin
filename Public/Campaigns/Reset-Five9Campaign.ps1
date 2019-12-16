<#
.SYNOPSIS
    
    Function to reset a campaign to redial every number, except for numbers on the Do-Not-Call list
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER CampaignName
 
    Campaign name to be reset

.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Reset-Five9Campaign -Five9AdminClient $adminClient -CampaignName 'Hot-Leads'

    # resets campaign named 'Hot-Leads'

#>
function Reset-Five9Campaign
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$CampaignName
    )

    return $Five9AdminClient.resetCampaign($CampaignName)

}
