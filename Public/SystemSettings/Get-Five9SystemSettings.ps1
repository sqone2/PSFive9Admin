function Get-Five9SystemSettings
{
    <#
    .SYNOPSIS

        Function used to get system settings for a Five9 domain such as domain name and domain id

    .EXAMPLE

        Get-Five9SystemSettings

        # Returns basic system settings for domain

    #>
    [CmdletBinding(PositionalBinding = $true)]
    param
    (

    )

    try
    {
        Test-Five9Connection -ApiName 'REST' -ErrorAction: Stop

        $response = Invoke-Five9RestApi -Method GET -Path 'system-settings'
        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning system settings for domain: $($response.domainName)"
        return $response


    }
    catch
    {
        $_ | Write-PSFive9AdminError
        $_ | Write-Error
    }
}


