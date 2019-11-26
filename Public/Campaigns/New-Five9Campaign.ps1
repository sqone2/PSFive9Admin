<#
.SYNOPSIS
    
    Function used to get campaign(s) from Five9
 
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER Type
 
    Campaign Type. Options are: INBOUND, OUTBOUND, AUTODIAL

.PARAMETER NamePattern
 
    Optional parameter. Returns only dispositions matching a given regex string

.NOTES

    Returning a single campaign also returns additional details that are NOT returned when multiple campaigns are returned.
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9Campaign -Five9AdminClient $adminClient -Type OUTBOUND
    
    # Returns basic info on all outbound campaigns
    
.EXAMPLE
    
    Get-Five9Campaign -Five9AdminClient $adminClient -Type OUTBOUND -NamePattern 'MultiMedia' 

    # Returns basic and additional info for outbound campaign with name "MultiMedia"
    
 
#>
function New-Five9Campaign
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,

        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][ValidateSet('INBOUND', 'OUTBOUND', 'AUTODIAL')][string]$Type


    )



    if ($Type -eq 'INBOUND')
    {

        $inboundCampaign = New-Object PSFive9Admin.inboundCampaign

        $inboundCampaign.name = $Name

        $inboundCampaign.type = $Type
        $inboundCampaign.typeSpecified = $true


        $response = $Five9AdminClient.createInboundCampaign($inboundCampaign)

    }


    


}

#New-Five9Campaign -Five9AdminClient $aacFive9AdminClient -Name "__TEST2" -Type: INBOUND
