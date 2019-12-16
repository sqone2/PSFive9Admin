<#
.SYNOPSIS
    
    Function to remove a single 10 digit DNIS, or multiple DNISes from an inbound campaign
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER CampaignName
 
    Inbound campaign name that a single 10 digit DNIS, or multiple DNISes will be removed from

.PARAMETER DNIS
 
    Single 10 digit DNIS, or array of multiple DNISes to be removed from an inbound campaign


.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9CampaignDNIS -Five9AdminClient $adminClient -CampaignName 'Hot-Leads' -DNIS '5991230001'

    # removes a single DNIS from a campaign

.EXAMPLE

    $dnisToBeRemoved = @('5991230001', '5991230002', '5991230003')
    Remove-Five9CampaignDNIS -Five9AdminClient $adminClient -CampaignName 'Hot-Leads' -DNIS $dnisToBeRemoved
    
    # removes multiple DNISes from a campaign
    
 
#>
function Remove-Five9CampaignDNIS
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$CampaignName,
        [Parameter(Mandatory=$true)][ValidatePattern('^\d{10}$')][string[]]$DNIS
    )

    return $Five9AdminClient.removeDNISFromCampaign($CampaignName, $DNIS)

}
