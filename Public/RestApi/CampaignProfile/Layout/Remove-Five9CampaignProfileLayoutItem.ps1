function Get-Five9CampaignProfileLayoutItem
{
    <#
    .SYNOPSIS

        Function getting the layout items assigned to a campaign profile

    .EXAMPLE

        Get-Five9CampaignProfileLayoutItem -ProfileName 'Inbound-Profile'
        # Gets all layout items assigned to a campaign profile


    .EXAMPLE

       Get-Five9CampaignProfileLayoutItem -ProfileName 'Inbound-Profile' -FieldTitle 'Primary'

        # Gets a single layout item with the Title of 'Primary'

    #>

    [CmdletBinding(DefaultParametersetName = 'Name', PositionalBinding = $false)]
    param
    (
        # Name of campaign profile to add layout item to
        [Parameter(ParameterSetName = 'Name', Mandatory = $true)][string]$ProfileName,

        # Id of campaign profile to add layout item to
        [Parameter(ParameterSetName = 'Id', Mandatory = $true)][string]$ProfileId,

        # Title of single laytout imte to remove
        [Parameter(Mandatory = $true)][string]$FieldTitle
    )

    try
    {
        Test-Five9Connection -ApiName 'REST' -ErrorAction: Stop

        if ($PSCmdlet.ParameterSetName -eq 'Name')
        {
            $fieldView = Get-Five9CampaignProfileLayoutItem -ProfileName $ProfileName -FieldTitle $FieldTitle
        }
        else
        {
            $fieldView = Get-Five9CampaignProfileLayoutItem -ProfileId $ProfileId -FieldTitle $FieldTitle
        }

        if ($fieldView) {

        }



    }
    catch
    {
        $_ | Write-PSFive9AdminError
        $_ | Write-Error
    }
}
