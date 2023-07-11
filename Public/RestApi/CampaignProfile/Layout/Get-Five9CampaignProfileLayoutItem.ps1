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

        # Title of single laytout imte to return
        # if omitted, all items will be returned
        [Parameter(Mandatory = $false)][string]$FieldTitle
    )

    try
    {
        Test-Five9Connection -ApiName 'REST' -ErrorAction: Stop

        if ($PSCmdlet.ParameterSetName -eq 'Name')
        {
            $campaignProfile = Get-Five9ObjectByName -Name $ProfileName -Type 'campaign-profiles'
            $ProfileId = $campaignProfile.id
        }

        if ($null -eq $ProfileId)
        {
            throw "Invalid ProfileId"
        }

        $queryParams = @{
            sort = 'order'
        }

        if ($PSBoundParameters.Keys -contains 'FieldTitle')
        {
            $queryParams += @{
                filter = "name=='$FieldTitle'"
            }
        }


        Write-Verbose "$($MyInvocation.MyCommand.Name): Getting all layout items assigned to Campaign Profile $ProfileName ($ProfileId)."

        Invoke-Five9RestApi -Method "GET" -Path "campaign-profiles/$ProfileId/field-views" -Body $body -QueryParams $queryParams -ErrorAction Stop


    }
    catch
    {
        $_ | Write-PSFive9AdminError
        $_ | Write-Error
    }
}
