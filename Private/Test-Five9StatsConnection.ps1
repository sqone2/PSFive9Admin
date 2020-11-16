function Test-Five9StatsConnection
{
    <#
    .SYNOPSIS
    
        Function used to test the connection to the Five9 Stats Web Service


    .EXAMPLE
    
        Test-Five9StatsConnection
    
        # Will throw exception if not connected
    
    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (

    )

    if ($global:Five9StatisticsClient.Credentials.UserName.Length -gt 1)
    {
        return
    }
        
    throw "You are not currently connected to the Five9 Statistics Web Service. You must first connect using Connect-Five9Statistics."
    return
}

        