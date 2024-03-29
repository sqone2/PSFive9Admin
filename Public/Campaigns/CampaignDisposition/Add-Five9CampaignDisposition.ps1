function Add-Five9CampaignDisposition
{
    <#
    .SYNOPSIS
    
        Function to add disposition(s) to a Five9 campaign
    .EXAMPLE
    
        Add-Five9CampaignDisposition -CampaignName 'MultiMedia' -DispositionName 'Wrong Number'

        # adds a single disposition to a campaign

    .EXAMPLE

        $dispositionsToBeAdded = @('Dead Air', 'Wrong Number')
        Add-Five9CampaignDisposition -CampaignName 'MultiMedia' -DispositionName $dispositionsToBeAdded
    
        # adds multiple dispositions to a campaign
    #>

    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # Campaign name that disposition(s) will be added to
        [Parameter(Mandatory=$true, Position=0)][Alias('Name')][string]$CampaignName,

        # Single disposition name, or multiple disposition names to be added to a campaign
        [Parameter(Mandatory=$true, Position=1)][string[]]$DispositionName,

        # For campaigns running in preview mode, whether the dispositions that are added should be used as skip call preview dispositions
        [Parameter(Mandatory=$false)][bool]$IsSkipPreviewDisposition = $false
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Adding disposition to campaign '$CampaignName'." 
        return $global:DefaultFive9AdminClient.addDispositionsToCampaign($CampaignName,$DispositionName,$IsSkipPreviewDisposition, $IsSkipPreviewDisposition)
    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
