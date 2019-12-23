function Reset-Five9CampaignDispositions
{
    <#
    .SYNOPSIS

        Resets the dispositions of the campaign list records that match the dispositions. Calls that
        occurred during the date and time interval are reset so that the contacts can be dialed
        again if their disposition included in the list of dispositions.
 
    .EXAMPLE
    
        Reset-Five9Campaign -Name 'Hot-Leads'

        # Resets campaign named 'Hot-Leads'

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # Campaign name to be reset
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # Disposition(s) to reset. Calls that have been dispositioned with the selected disposition(s) will be reset and will be called again.
        [Parameter(Mandatory=$true)][string[]]$Dispositions,

        # Date you would like to start resetting disposition(s) on
        [Parameter(Mandatory=$true)][datetime]$StartDateTime,

        # Date you would like to stop resetting disposition(s) on
        [Parameter(Mandatory=$true)][datetime]$EndDateTime
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Resetting dispostions on campaign '$Name'." 
        return $global:DefaultFive9AdminClient.resetCampaignDispositions($Name)

    }
    catch
    {
        Write-Error $_
    }

}
