<#
.SYNOPSIS
    
    Function used to delete an existing campaign in Five9
 
.PARAMETER Name

    Name of existing campaign to be removed

.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9InboundCampaign -Five9AdminClient $adminClient -Name "Cold-Calls"
    
    # Removes campaign named "Cold-Calls"

#>
function Remove-Five9Campaign
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name
    )

    $response = $Five9AdminClient.deleteCampaign($Name)

    return $response

}

