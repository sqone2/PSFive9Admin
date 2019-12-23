function Reset-Five9CampaignDisposition
{
    <#
    .SYNOPSIS

        Resets the dispositions of the campaign list records that match the dispositions. Calls that
        occurred during the date and time interval are reset so that the contacts can be dialed
        again if their disposition included in the list of dispositions.
 
    .EXAMPLE
    
        Reset-Five9CampaignDisposition "Hot-Leads" -Disposition "Busy", "No Answer" -StartDateTime '2019-12-20'

        # Resets dispostion "Busy" and "No Answer" on campaign named 'Hot-Leads' from '2019-12-20' to the current date and time

    .EXAMPLE

        Reset-Five9CampaignDisposition "Hot-Leads" -Disposition "Busy", "No Answer" -StartDateTime '2019-12-01 05:30:00' -EndDateTime '2019-12-30' -Verbose

        # Resets specifed dispostions between the specified date and times

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Campaign name to be reset
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # Single dispostion name, or array of multiple disposition to be reset
        [Parameter(Mandatory=$true)][string[]]$Disposition,

        # Date you would like to start resetting disposition(s) on
        [Parameter(Mandatory=$true)][datetime]$StartDateTime,

        # Date you would like to stop resetting disposition(s) on
        # If omitted, the current date and time will be used
        [Parameter(Mandatory=$false)][datetime]$EndDateTime = (Get-Date)
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Resetting dispostions on campaign '$Name' between '$($StartDateTime.ToString('s'))' - '$($EndDateTime.ToString('s'))'."
        return $global:DefaultFive9AdminClient.resetCampaignDispositions($Name, $Disposition, $StartDateTime.ToString('s'), $true, $EndDateTime.ToString('s'), $true)

    }
    catch
    {
        Write-Error $_
    }

}
