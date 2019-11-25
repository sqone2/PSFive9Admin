<#
.SYNOPSIS
    
    Function used to get campaign(s) from Five9
 
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client

.PARAMETER Type
 
    Campaign Type. Options are: INBOUND, OUTBOUND, AUTODIAL

.PARAMETER NamePattern
 
    Optional parameter. Returns only dispositions matching a given regex string
   
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9Campaign -Five9AdminClient $adminClient -Type OUTBOUND
    
    # Returns all outbound campaigns
    
.EXAMPLE
    
    Get-Five9Campaign -Five9AdminClient $adminClient -Type OUTBOUND -NamePattern 'MultiMedia' 

    # Returns outbound campaign with name "MultiMedia"
    
 
#>
function Get-Five9Campaign
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][ValidateSet('OUTBOUND', 'INBOUND', 'AUTODIAL')][string]$Type,
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
        
    )


    return $Five9AdminClient.getCampaigns($NamePattern, $Type, $true)

}

