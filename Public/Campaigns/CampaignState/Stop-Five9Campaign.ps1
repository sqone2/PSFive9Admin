function Stop-Five9Campaign
{
    <#
    .SYNOPSIS
    
        Function to stop a campaign

    .EXAMPLE
    
        Stop-Five9Campaign -Name 'Hot-Leads'

        # Stops campaign named 'Hot-Leads' gracefully

    .EXAMPLE
    
        Stop-Five9Campaign -Name 'Hot-Leads' -Force $true

        # Stops campaign named 'Hot-Leads' forcefully, which immediately disconnects all active calls
    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Campaign name that will be stopped
        [Parameter(Mandatory=$true)][string]$Name,

        # Force stops the campaign, which immediately disconnects all active calls
        [Parameter(Mandatory=$false)][bool]$Force = $false
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        if ($Force -eq $true)
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Stopping campaign '$Name'." 
            return $global:DefaultFive9AdminClient.forceStopCampaign($Name)
        }
        else
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Forcefully stopping campaign '$Name'." 
            return $global:DefaultFive9AdminClient.stopCampaign($Name)
        }

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
