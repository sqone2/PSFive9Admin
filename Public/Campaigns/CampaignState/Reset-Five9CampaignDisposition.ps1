function Reset-Five9CampaignDisposition
{
    <#
    .SYNOPSIS

        Resets the dispositions of the campaign list records that match the dispositions. Calls that
        occurred during the date and time interval are reset so that the contacts can be dialed
        again if their disposition included in the list of dispositions.
 
    .EXAMPLE
    
        Reset-Five9CampaignDisposition -CampaignName "InboundCampaign" -Disposition "Busy", "No Answer" -StartDateTime '2019-12-20'

        # Resets disposition "Busy" and "No Answer" on campaign named 'InboundCampaign' from '2019-12-20' to the current date and time

    .EXAMPLE

        Reset-Five9CampaignDisposition -CampaignName "InboundCampaign" -Disposition "Busy", "No Answer" -StartDateTime '2019-12-01 05:30:00' -EndDateTime '2019-12-30' -Verbose

        # Resets specifed dispositions between the specified date and times

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Campaign name to be reset
        [Parameter(Mandatory=$true, Position=0)][Alias('Name')][string]$CampaignName,

        # Single disposition name, or array of multiple disposition to be reset
        [Parameter(Mandatory=$true, Position=1)][string[]]$Disposition,

        # Date you would like to start resetting disposition(s) on
        [Parameter(Mandatory=$true)][datetime]$StartDateTime,

        # Date you would like to stop resetting disposition(s) on
        # If omitted, the current date and time will be used
        [Parameter(Mandatory=$false)][datetime]$EndDateTime = (Get-Date)
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Resetting dispositions on campaign '$CampaignName' between '$($StartDateTime.ToString('s'))' - '$($EndDateTime.ToString('s'))'."
        return $global:DefaultFive9AdminClient.resetCampaignDispositions($CampaignName, $Disposition, $StartDateTime.ToString('s'), $true, $EndDateTime.ToString('s'), $true)

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}
