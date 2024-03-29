function Remove-Five9CampaignDisposition
{
    <#
    .SYNOPSIS
    
        Function removes disposition(s) from a Five9 campaign

    .EXAMPLE
    
        Remove-Five9CampaignDisposition -CampaignName 'MultiMedia' -DispositionName 'Wrong Number'

        # Removes a single disposition from a campaign

    .EXAMPLE

        $dispositionsToBeRemoved = @('Dead Air', 'Wrong Number')
        Remove-Five9CampaignDisposition -CampaignName 'MultiMedia' -DispositionName $dispositionsToBeRemoved
    
        # Removes multiple dispositions from a campaign

    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Campaign that disposition(s) will be removed from
        [Parameter(Mandatory=$true)][Alias('Name')][string]$CampaignName,

        # Single disposition name, or multiple disposition names to be added removed from a campaign
        [Parameter(Mandatory=$true)][string[]]$DispositionName
    )
    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing disposition from campaign '$CampaignName'." 
        return $global:DefaultFive9AdminClient.removeDispositionsFromCampaign($CampaignName, $DispositionName)

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}

