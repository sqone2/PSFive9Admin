function Get-QueryParamString
{
    <#
    .SYNOPSIS

        Converts hashtable to querystring

    .EXAMPLE

        Get-QueryParamString -QueryParams @{fname='John';lname='Doe'}

        # returns fname=John&lname=Doe

    #>
    [CmdletBinding(PositionalBinding = $true)]
    param
    (
        # Hashtable to be converted to query string
        [Parameter(Mandatory = $true)][hashtable]$QueryParams
    )

    if ($QueryParams.Count -lt 1)
    {
        return ''
    }


    $paramList = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    foreach ($paramName in $QueryParams.Keys)
    {
        $paramValue = $QueryParams.$paramName

        if ($paramValue.GetType().BaseType.Name -match 'Array')
        {
            $paramValue = $paramValue -join ','
        }

        $paramList.Add($paramName, $paramValue)
    }


    return $paramList.ToString()

}

