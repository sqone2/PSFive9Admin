function Get-Five9ObjectByName
{
    <#
    .SYNOPSIS

        Helper function for getting a single object using it's Name property

    .EXAMPLE

        Get-Five9ObjectByName -Name 'MyCampaign' -Type 'campaigns'

        # adds a single DNIS to a campaign


    #>

    [CmdletBinding(PositionalBinding = $true)]
    param
    (
        # Name of object to fetch
        [Parameter(Mandatory = $true)][ValidateLength(2, 255)][string]$Name,

        # Type of object. i.e. 'campaigns' or 'skills'
        [Parameter(Mandatory = $true)][string]$Type,

        # Whether error should be thrown if specified object is not found
        [Parameter(Mandatory = $false)][bool]$ErrorIfNotFound = $true

    )

    try
    {
        Test-Five9Connection -ApiName 'REST' -ErrorAction: Stop

        $queryParams = @{
            limit  = 1
            filter = "name=='$Name'"
        }

        if ($Type -eq 'call-variables')
        {
            $queryParams.filter = "fullName=='$Name'"
        }



        $response = Invoke-Five9RestApi -Method GET -Path $Type -QueryParams $queryParams -ErrorAction: Stop

        if ($null -eq $response)
        {
            if ($ErrorIfNotFound -eq $true)
            {
                throw "Error. Not able to find object named ""$Name"" in list of ""$Type""."
            }
            else
            {
                return $null
            }
        }

        if ($response.Count -gt 1)
        {
            throw "Error. Multiple $Type found with name ""$Name"""
        }

        return $response | select -First 1



    }
    catch
    {
        throw $_
    }
}

