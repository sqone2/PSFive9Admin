 function ConvertTo-EpochTime
{
    <#
    .SYNOPSIS
    
        Function used to convert a dateTime object to an epoch time string

    .EXAMPLE

        ConvertTo-EpochTime -DateTimeInput '5/2/2022 3:15pm'

        # returns 1651518900000

    #>

    param
    (
        [datetime]$DateTimeInput
    )

    $utc = $DateTimeInput.ToUniversalTime()
    $epochTime = Get-Date -Date $utc -UFormat '%s'

    #another way
    # (New-TimeSpan -Start (Get-Date "01/01/1970") -End (([datetime]"5/2/2022 12:15am").ToUniversalTime())).TotalMilliseconds

    return [long]$epochTime * 1000

} 

