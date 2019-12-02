<#
.SYNOPSIS
    
    Function to remove disposition(s) from a Five9 campaign
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER CampaignName
 
    Campaign name that disposition(s) will be removed from

.PARAMETER DispositionName
 
    Single disposition name, or array multiple disposition names to be removed from a campaign


.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9CampaignDisposition -Five9AdminClient $adminClient -CampaignName 'MultiMedia' -DispositionName 'Wrong Number'

    # removes a single disposition from a campaign

.EXAMPLE

    $dispositionsToBeRemoved = @('Dead Air', 'Wrong Number')
    Remove-Five9CampaignDisposition -Five9AdminClient $adminClient -CampaignName 'MultiMedia' -DispositionName $dispositionsToBeRemoved
    
    # removes multiple dispositions from a campaign
    
 
#>
function Remove-Five9CampaignDisposition
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$CampaignName,
        [Parameter(Mandatory=$true)][string[]]$DispositionName
    )

    return $Five9AdminClient.removeDispositionsFromCampaign($CampaignName,$DispositionName)

}
